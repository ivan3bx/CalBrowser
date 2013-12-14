//
//  CABLCalendar.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/2/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * A container for resources (rooms, etc..)
 */
@interface CABLResourceLoader : NSObject

/*
 * Initializes this instance with the default app domain
 */
-(id)init;

/*
 * Initializes this instance with existing data
 */
-(id)initWithData:(NSData *)data;

/*
 * Initializes this instance with a Google Apps domain
 */
-(id)initWithAppDomain:(NSString *)appDomain;

/*
 * Loads and initializes resources, replacing any existing
 * resources.  In the case where this instance was initialized
 * with an app domain, will fetch all this data from the network.
 */
-(void)loadResources:(void (^)(NSArray *resources))onSuccess
               error:(void (^)(NSError *error))onError;

@end
