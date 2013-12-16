//
//  CALBConstants.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/1/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "CABLConfig.h"

NSString *const  kDefaultAccount      = @"OAuthCredentials";
NSString *const  kDefaultRegionName   = @"DefaultRegionName";
NSString *const  kDefaultCityName     = @"DefaultCityName";
NSString *const  kDefaultLocationName = @"DefaultLocationName";
NSString *const  kDefaultFloorNumber  = @"DefaultFloorNumber";
NSString *const  kAppsDomainKey       = @"GoogleAppsDomainKey";
NSString *const  kDatabasePathKey     = @"CABLDatabasePath";
NSUInteger const kMeetingLengthInMinutes = 30;
/*
 * Paths and important configuration values
 */
NSString *const kDatabaseFilePath = @"%@/Library/Caches/resources.db";

// Shared instance of this configuration class
CABLConfig *INSTANCE;

@interface CABLConfig() {
    NSUserDefaults *prefs;
}

@end

@implementation CABLConfig

+ (CABLConfig *)sharedInstance
{
    @synchronized([CABLConfig class]) {
        if (INSTANCE == nil) {
            INSTANCE = [[CABLConfig alloc] init];
        }
    }
    return INSTANCE;
}

- (id)init
{
    self = [super init];
    if (self) {
        prefs = [NSUserDefaults standardUserDefaults];
        [prefs registerDefaults:@{kDefaultAccount  : @"",
                                  kDatabasePathKey : [NSString stringWithFormat:kDatabaseFilePath, NSHomeDirectory()],
                                  kDefaultCityName : @"Chicago" // Chicago.. always Chicago..
                                  }
         ];
    }
    return self;
}

- (NSString *)appsDomainConfigPath
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [bundle pathForResource:@"apps-domain" ofType:@"json"];
}

- (CABLUser *)currentAccount
{
    id data = [prefs objectForKey:kDefaultAccount];

    if ([data isKindOfClass:[NSData class]]) {
        data = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }

    if ([data isKindOfClass:[CABLUser class]]) {
        return data;
    }
    
    return nil;
}

- (void)setCurrentAccount:(CABLUser *)account
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:account];
    [prefs setObject:data forKey:kDefaultAccount];
}

- (NSString *)currentRegion
{
    return [prefs stringForKey:kDefaultRegionName];
}

- (void)setCurrentRegion:(NSString *)currentRegion
{
    [prefs setObject:currentRegion forKey:kDefaultRegionName];
}

- (NSString *)currentCity
{
    return [prefs stringForKey:kDefaultCityName];
}

- (void)setCurrentCity:(NSString *)currentCity
{
    [prefs setObject:currentCity forKey:kDefaultCityName];
}

- (NSString *)currentLocation
{
    return [prefs stringForKey:kDefaultLocationName];
}

- (void)setCurrentLocation:(NSString *)currentLocation
{
    [prefs setObject:currentLocation forKey:kDefaultLocationName];
}

- (NSNumber *)currentFloor
{
    return [prefs objectForKey:kDefaultFloorNumber];
}

- (void)setCurrentFloor:(NSNumber *)currentFloor
{
    [prefs setObject:currentFloor forKey:kDefaultFloorNumber];
}

- (NSString *)databasePath
{
    return [prefs stringForKey:kDatabasePathKey];
}

@end
