//
//  CALBConstants.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/1/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOAuth2.h"

/*
 * User defaults
 */
extern NSString* const kDefaultAccount;
extern NSString* const kAppsDomainKey;

@interface CABLConfig : NSObject

+(CABLConfig *)sharedInstance;

@property(nonatomic, readwrite) NXOAuth2Account *currentAccount;
@property(nonatomic, readwrite) NSString *appsDomain;

@end
