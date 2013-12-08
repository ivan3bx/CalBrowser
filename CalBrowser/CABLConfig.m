//
//  CALBConstants.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/1/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import "CABLConfig.h"

NSString *const kDefaultAccount  = @"OAuthCredentials";
NSString *const kAppsDomainKey   = @"GoogleAppsDomainKey";
NSString *const kDatabasePathKey = @"CABLDatabasePath";

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
        [prefs registerDefaults:@{kDefaultAccount : @"",
                                  kDatabasePathKey : [NSString stringWithFormat:kDatabaseFilePath, NSHomeDirectory()]
                                  }
         ];
    }
    return self;
}

- (NXOAuth2Account *)currentAccount
{
    id data = [prefs objectForKey:kDefaultAccount];
    if ([data isKindOfClass:[NSData class]]) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else {
        return nil;
    }
}

- (void)setCurrentAccount:(NXOAuth2Account *)account
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:account];
    [prefs setObject:data forKey:kDefaultAccount];
}

- (NSString *)databasePath
{
    return [prefs stringForKey:kDatabasePathKey];
}

@end
