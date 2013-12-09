//
//  CABLFreeList.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/8/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CABLFreeList : NSObject

/*
 * Init with required parameters
 * - startTime : the desired start of the meeting
 * - endTime   : the desired end of the meeting
 */
-(id)initWithRange:(NSDate *)startTime ending:(NSDate *)endTime;

/*
 * Loads data & calls back appropriately
 */
-(void)load:(void (^)(CABLFreeList *))onSuccess error:(void (^)(NSError *))onError;

@end
