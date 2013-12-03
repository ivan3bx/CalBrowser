//
//  CABLCalendar.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/2/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * A container for resources (rooms, etc..)
 */
@interface CABLResourceList : NSObject

+(void)loadResourceList:(void (^)(CABLResourceList *))onSuccess error:(void (^)(NSError *))onError;

@end
