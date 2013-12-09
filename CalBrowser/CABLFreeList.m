//
//  CABLFreeList.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/8/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import <NXOAuth2.h>
#import "CABLConfig.h"
#import "CABLFreeList.h"
#import "CABLResourceList.h"
#import "CABLResource.h"

typedef void(^SuccessHandler)(CABLFreeList *);
typedef void(^ErrorHandler)(NSError *);

@interface CABLFreeList() {
    NSMutableArray *_entries;
    NSMutableData *_data;
}

@property(nonatomic,readonly)NSDate *startTime;
@property(nonatomic,readonly)NSDate *endTime;
@property(nonatomic,readwrite,copy) SuccessHandler successHandler;
@property(nonatomic,readwrite,copy) ErrorHandler errorHandler;

@end

@implementation CABLFreeList

-(id)initWithRange:(NSDate *)startTime ending:(NSDate *)endTime;
{
    self = [super init];
    if (self) {
        _startTime = startTime;
        _endTime   = endTime;
    }
    return self;
}

-(void)load:(void (^)(CABLFreeList *))onSuccess error:(void (^)(NSError *))onError
{
    //
    // First let's make sure resources have been loaded
    //
    
    //
    // Load a new request for free/busy
    //
    NSArray *resources = @[]; // <-- TODO: this should be a list of resources
    NSURL *url;
    NXOAuth2Request *request;

    url = [NSURL URLWithString:@"https://www.googleapis.com/calendar/v3/freeBusy"];
    request =  [[NXOAuth2Request alloc] initWithResource:url
                                                  method:@"POST"
                                              parameters:nil];
    request.account = [[CABLConfig sharedInstance] currentAccount];
    [self load:[[request signedURLRequest] mutableCopy] forResources:resources];
}

-(void)load:(NSMutableURLRequest *)urlRequest forResources:(NSArray *)resources
{
    /*
     {
     "timeMin": "2013-12-09T08:00:00-06:00",
     "timeMax": "2013-12-09T17:00:00-06:00",
     "calendarExpansionMax": 10,
     "timeZone": "America/Chicago",
     "items": [
     {
     "id": "groupon.com_3433343530333233333231@resource.calendar.google.com"
     }
     ]
     }
     */
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (CABLResource *resource in resources) {
        [items addObject:@{@"id" : resource.email}];
    }

    NSDictionary   *dict = @{@"timeMin"              : @"startTime",
                             @"timeMax"              : @"endTime",
                             @"timeZone"             : [[NSTimeZone systemTimeZone] name],
                             @"calendarExpansionMax" : @10,
                             @"items"                : items };
    
    NSError *error;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (!error) {
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setHTTPBody:bodyData];
        [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    } else {
        [NSException raise:NSGenericException format:@"Invalid POST data [%@]", error.userInfo];
    }
}

#pragma mark -
#pragma mark NSURLConnectionDelegate methods
#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    if (response.statusCode != 200) {
        NSDictionary *dict = @{@"statusCode" : [NSNumber numberWithInt:(int)response.statusCode],
                               @"message"    : @"Calendar resource list failed to load data"};
        if (self.errorHandler) {
            self.errorHandler([NSError errorWithDomain:@"CalBrowser" code:1 userInfo:dict]);
        } else {
            NSLog(@"%@", dict);
        }
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
    // Parse _data
}

@end
