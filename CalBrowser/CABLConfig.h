//
//  CALBConstants.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/1/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CABLUser.h"

/*
 * User defaults
 */
extern NSString*  const kDefaultAccount;
extern NSString*  const kAppsDomainKey;
extern NSString*  const kDatabasePathKey;
extern NSUInteger const kMeetingLengthInMinutes;

@interface CABLConfig : NSObject

+(CABLConfig *)sharedInstance;

@property(nonatomic, readwrite) CABLUser *currentAccount;

/*
 * Location preferences
 */
@property(nonatomic, readwrite) NSString *currentRegion;
@property(nonatomic, readwrite) NSString *currentCity;
@property(nonatomic, readwrite) NSString *currentLocation;
@property(nonatomic, readwrite) NSNumber *currentFloor;

@property(nonatomic, readwrite) NSString *appsDomainName;
@property(nonatomic, readwrite) NSString *databasePath;
@end
