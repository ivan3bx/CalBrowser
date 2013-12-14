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
    
    if (_appDomain) {
        //
        // Fetch from the network
        //
        [self loadFromNetwork:onSuccess handleError:onError];
    } else {
        //
        // Fetch from static data
        //
        [_parser parseWithData:_data];
        [self save];
        _data = nil;
        onSuccess([CABLResource findAll]);
    }
}

/*
 * This method decides whether we should rely on cached resource information
 */
- (BOOL)shouldFetchFromCache
{
    return [CABLResource numberOfEntries] > 0;
}

-(void)loadFromNetwork:(SuccessHandler)onSuccess handleError:(ErrorHandler)onError
{
    self.successHandler = onSuccess;
    self.errorHandler = onError;
    
    NSString *const BASE_URL    = @"https://apps-apis.google.com/a/feeds/calendar/resource/2.0";
    NSString *urlStringWithDomain = [NSString stringWithFormat:@"%@/%@/", BASE_URL, _appDomain];
    [self load:[self createRequest:urlStringWithDomain]];
}

-(NSURLRequest *)createRequest:(NSString *)urlString
{
    NXOAuth2Request *signedReq;
    signedReq = [[NXOAuth2Request alloc] initWithResource:[NSURL URLWithString:urlString]
                                                   method:@"GET"
                                               parameters:nil];
    
    //
    // Associate current user's account with this request
    //
    signedReq.account = [CABLConfig sharedInstance].currentAccount;
    
    //
    // Append content-type (since this API is XML)
    //
    NSMutableURLRequest *xmlRequest = [signedReq.signedURLRequest mutableCopy];
    [xmlRequest addValue:@"application/atom+xml" forHTTPHeaderField:@"Content-type"];
    return xmlRequest;
}

-(void)load:(NSURLRequest *)request
{
    [NSURLConnection connectionWithRequest:request delegate:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

/*
 * Save anything we parsed
 */
-(void)save
{
    for (NSDictionary *dict in [_parser entries]) {
        CABLResource *resource = [[CABLResource alloc] initWithData:dict];
        [resource save];
    }
}

#pragma mark -
#pragma mark NSURLConnectionDelegate methods
#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    if (response.statusCode != 200) {
        NSDictionary *dict = @{@"statusCode" : [NSNumber numberWithInt:(int)response.statusCode],
                               @"message"    : @"Calendar resource list failed to load any data"};
        if (self.errorHandler) {
            self.errorHandler([NSError errorWithDomain:@"CalBrowser" code:1 userInfo:dict]);
        }
        [connection cancel];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (_data == nil) {
        _data = [NSMutableData dataWithData:data];
    } else {
        [_data appendData:data];
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    //
    // Parse any data
    //
    [_parser parseWithData:_data];
    _data = nil;
    
    [self save];
    
    //
    // Load more, or complete
    //
    if ([_parser hasMoreData]) {
        NSURLRequest *nextReq = [self createRequest:[_parser nextURI]];
        [self load:nextReq];
    } else {
        self.successHandler([CABLResource findAll]);
    }
}

@end









