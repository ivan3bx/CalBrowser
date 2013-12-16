//
//  CABLFreeList.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/8/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
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
-(void)load:(void (^)(CABLFreeList *freeList))onSuccess error:(void (^)(NSError *error))onError;

@property(nonatomic,readonly,copy) NSArray *freeResources;
@end
