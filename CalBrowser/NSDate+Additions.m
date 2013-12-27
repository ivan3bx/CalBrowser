//
//  NSDate+Additions.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/26/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

-(NSDate *)dateForCurrentHalfHour
{
    NSDateComponents *components = [self componentsFromDate];
    
    if ([components minute] < 25) {
        components.minute = 0;
    } else if ([components minute] < 55) {
        components.minute = 30;
    } else {
        components.minute = 0;
        components.hour = components.hour + 1;
    }
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    return [cal dateFromComponents:components];
}

-(NSDate *)dateForNextHalfHour
{
    NSDateComponents *components = [self componentsFromDate];
    
    if ([components minute] < 25) {
        components.minute = 30;
    } else if ([components minute] < 55) {
        components.minute = 00;
        components.hour = components.hour + 1;
    } else {
        components.minute = 30;
        components.hour = components.hour + 1;
    }
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    return [cal dateFromComponents:components];
}

-(NSDateComponents *)componentsFromDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar components:
            NSTimeZoneCalendarUnit
            | NSYearCalendarUnit
            | NSMonthCalendarUnit
            | NSDayCalendarUnit
            | NSHourCalendarUnit
            | NSMinuteCalendarUnit fromDate:self];
}
@end
