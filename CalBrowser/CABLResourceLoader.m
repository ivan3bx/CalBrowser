//
//  CABLCalendar.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/2/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "CABLResourceLoader.h"
#import "CABLResource.h"
#import "CABLConfig.h"
#import "CABLUser.h"
#import "CABLResourceParser.h"


typedef void(^SuccessHandler)(NSArray *resources);
typedef void(^ErrorHandler)(NSError *error);

@interface CABLResourceLoader() {
    NSString *_appDomain;
    NSMutableData *_data;
    CABLResourceParser *_parser;
}

@property(nonatomic,readwrite,copy) SuccessHandler successHandler;
@property(nonatomic,readwrite,copy) ErrorHandler errorHandler;

@end

@implementation CABLResourceLoader

- (id)init
{
    self = [super init];
    if (self) {
        self = [self initWithAppDomain:[[CABLConfig sharedInstance] appsDomainName]];
    }
    return self;
}

-(id)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        _data = [data mutableCopy];
        _parser = [[CABLResourceParser alloc] init];
    }
    return self;
}

-(id)initWithAppDomain:(NSString *)appDomain
{
    self = [super init];
    if (self) {
        _appDomain = appDomain;
        _parser = [[CABLResourceParser alloc] init];
    }
    return self;
}

-(void)loadResources:(void (^)(NSArray *resources))onSuccess
               error:(void (^)(NSError *error))onError
{
    if ([self shouldFetchFromCache]) {
        onSuccess([CABLResource findAll]);
        return;
    }

    [CABLResource reset];

    self.successHandler = onSuccess;
    self.errorHandler = onError;
    
    if (_appDomain) {
        //
        // Fetch from the network
        //
        [self loadFromNetwork];
    } else {
        //
        // Fetch from static data
        //
        [self loadFromData];
    }
}

/*
 * This method decides whether we should rely on cached resource information
 */
- (BOOL)shouldFetchFromCache
{
    NSUInteger cacheCount = [CABLResource numberOfEntries];
    return cacheCount > 0;
}

-(void)loadFromData
{
    [_parser parseWithData:_data];
    [self save];

    _data = nil;
    self.successHandler([CABLResource findAll]);
}

-(void)loadFromNetwork
{
    NSString *baseURL    = @"https://apps-apis.google.com/a/feeds/calendar/resource/2.0";
    [self doLoadFromNetwork:[NSString stringWithFormat:@"%@/%@/", baseURL, _appDomain]];
}

-(void)doLoadFromNetwork:(NSString *)urlString
{
    CABLUser *user = [CABLConfig sharedInstance].currentAccount;
    
    [user getXML:urlString
      parameters:nil
       onSuccess:^(NSData *data) {
           //
           // Parse any data
           //
           [_parser parseWithData:data];
           [self save];
           
           if ([_parser hasMoreData]) {
               //
               // Load more
               //
               [self doLoadFromNetwork:[_parser nextURI]];
           } else {
               //
               // Completed
               //
               self.successHandler([CABLResource findAll]);
           }
       } onError:^(NSError *error) {
           self.errorHandler(error);
       }];
}

/*
 * Save anything we have parsed
 */
-(void)save
{
    for (NSDictionary *dict in [_parser entries]) {
        CABLResource *resource = [[CABLResource alloc] initWithData:dict];
        [resource save];
    }
}

@end









