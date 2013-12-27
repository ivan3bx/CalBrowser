//
//  NSDate+Additions.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/26/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Additions)
-(NSDate *)dateForCurrentHalfHour;
-(NSDate *)dateForNextHalfHour;
-(NSDateComponents *)componentsFromDate;
@end
