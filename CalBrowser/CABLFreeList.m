//
//  CABLFreeList.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/8/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <NXOAuth2.h>
#import "CABLConfig.h"
#import "CABLFreeList.h"
#import "CABLResourceLoader.h"
#import "CABLResource.h"
#import "CABLUser.h"

typedef void(^SuccessHandler)(CABLFreeList *freeList);
typedef void(^ErrorHandler)(NSError *error);

@interface CABLFreeList() {
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
    // Load a new request for free/busy
    //
    NSString *resourceNamePrefix = [self resolveResourcePrefix];
    NSArray *resources = [CABLResource findAllByNamePrefix:resourceNamePrefix];
    [self load:@"https://www.googleapis.com/calendar/v3/freeBusy" forResources:resources];
}

-(void)load:(NSString *)urlString forResources:(NSArray *)resources
{
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
    
    CABLUser *user = [CABLConfig sharedInstance].currentAccount;
    
    [user postJSON:urlString
              body:@{@"timeMin"              : [format stringFromDate:self.startTime],
                     @"timeMax"              : [format stringFromDate:self.endTime],
                     @"timeZone"             : [[NSTimeZone systemTimeZone] name],
                     @"calendarExpansionMax" : @80,
                     @"items"                : items}
         onSuccess:^(NSDictionary *data) {
             //
             // Process results!
             //
             _freeResources = [[NSMutableArray alloc] init];

             data = data[@"calendars"];
             [data enumerateKeysAndObjectsUsingBlock:^(NSString     *resourceEmail,
                                                       NSDictionary *resourceAvailability,
                                                       BOOL         *stop) {
                 NSArray *busyBlocks   = resourceAvailability[@"busy"];
                 NSArray *errorEntries = resourceAvailability[@"errors"];
                 
                 if (errorEntries.count == 0 && busyBlocks.count == 0) {
                     //
                     // Absence of entries in this array == not booked, and therefore 'free'
                     //
                     [(NSMutableArray *)_freeResources addObject:[CABLResource findByEmail:resourceEmail]];
                 }
             }];
             self.successHandler(self);
         } onError:^(NSError *error) {
             self.errorHandler(error);
         }];
}

-(NSString *)resolveResourcePrefix
{
    NSString *location = [CABLConfig sharedInstance].currentLocation;
    NSNumber *floor = [CABLConfig sharedInstance].currentFloor;
    
    NSString *result;
    if ([CABLConfig sharedInstance].currentFloor) {
        result = [NSString stringWithFormat:@"%@-%@", location, floor];
    } else {
        result = location;
    }
    NSLog(@"Searching with prefix: '%@'", result);
    return result;
}

@end
