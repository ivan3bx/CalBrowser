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
@interface CABLResourceList : NSObject

+(void)loadResourceList:(void (^)(NSArray *resources))onSuccess error:(void (^)(NSError *error))onError;

-(id)initWithData:(NSData *)data;
-(NSUInteger)count;
-(NSDictionary *)resourceForIndex:(NSUInteger)index;

@end
