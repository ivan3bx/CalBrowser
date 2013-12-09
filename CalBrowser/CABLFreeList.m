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

typedef void(^SuccessHandler)(CABLFreeList *freeList);
typedef void(^ErrorHandler)(NSError *error);

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

-(void)load:(SuccessHandler)onSuccess error:(ErrorHandler)onError;
{
    self.successHandler = onSuccess;
    self.errorHandler = onError;
    
    //
    // First let's make sure resources have been loaded
    //
    [CABLResourceList loadResourceList:^(NSArray *data) {
        //
        // Load a new request for free/busy
        //
        NSString *resourceNamePrefix = @"__REPLACE ME__"; // TODO: To be configuration-driven
        NSArray *resources = [CABLResource findAllByNamePrefix:resourceNamePrefix];
        if (resources.count == 0) {
            NSLog(@"WARN: No resources found for prefix: '%@'.", resourceNamePrefix);
        }
        
        NSURL *url;
        NXOAuth2Request *request;
        
        url = [NSURL URLWithString:@"https://www.googleapis.com/calendar/v3/freeBusy"];
        request =  [[NXOAuth2Request alloc] initWithResource:url
                                                      method:@"POST"
                                                  parameters:nil];
        request.account = [[CABLConfig sharedInstance] currentAccount];
        [self load:[[request signedURLRequest] mutableCopy] forResources:resources];
    } error:^(NSError *error) {
        self.errorHandler(error);
    }];
}

-(void)load:(NSMutableURLRequest *)urlRequest forResources:(NSArray *)resources
{
    NSDictionary *dict;
    NSDateFormatter *format;
    
    format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    
    //
    // Construct the list of 'items' in the body
    //
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (CABLResource *resource in resources) {
        [items addObject:@{@"id" : resource.email}];
    }

    //
    // Construct the body itself
    //
    dict = @{@"timeMin"              : [format stringFromDate:self.startTime],
             @"timeMax"              : [format stringFromDate:self.endTime],
             @"timeZone"             : [[NSTimeZone systemTimeZone] name],
             @"calendarExpansionMax" : @80,
             @"items"                : items };

    //    dict = @{@"timeMin"            : @"2013-12-09T16:30:00-06:00",
    //           @"timeMax"              : @"2013-12-09T17:00:00-06:00",
    //           @"timeZone"             : [[NSTimeZone systemTimeZone] name],
    //           @"calendarExpansionMax" : @80,
    //           @"items"                : items };
    
    //
    // Encode body as JSON and connect
    //
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

-(NSArray *)freeResources
{
    return [_entries copy];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate methods
#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    if (response.statusCode != 200) {
        NSDictionary *dict = @{@"statusCode" : [NSNumber numberWithInt:(int)response.statusCode],
                               @"message"    : @"Free List failed to load any data"};
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
    NSError *error;
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:_data
                                                            options:NSJSONReadingAllowFragments
                                                              error:&error][@"calendars"];
    if (error) {
        //
        // Handle the error
        //
        self.errorHandler(error);
    } else if (results == nil) {
        //
        // Empty data?
        //
        NSLog(@"FreeList returned empty calendar data. %@", [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding]);
        self.successHandler(self);
    } else {
        //
        // Process results!
        //
        _entries = [[NSMutableArray alloc] init];
        [results enumerateKeysAndObjectsUsingBlock:^(NSString     *resourceEmail,
                                                     NSDictionary *resourceAvailability,
                                                     BOOL         *stop) {
            NSArray *busyBlocks = resourceAvailability[@"busy"];
            
            if (busyBlocks.count == 0) {
                //
                // Absence of entries in this array == not booked, and therefore 'free'
                //
                [_entries addObject:[CABLResource findByEmail:resourceEmail]];
            }
        }];
        
        self.successHandler(self);
    }
}

@end
