//
//  CircleLineButton.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/6/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import "ClockButton.h"

@interface ClockButton ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@end

@implementation ClockButton

/*
 * Set the value for this button to be the half-hour closest or preceeding the reference date
 */
-(void)setTimeForPreviousHalfHourFrom:(NSDate *)referenceDate
{
    NSDateComponents *components = [self componentsFromDate:referenceDate];

    if ([components minute] < 25) {
        components.minute = 0;
    } else if ([components minute] < 55) {
        components.minute = 30;
    } else {
        components.minute = 0;
        components.hour = components.hour + 1;
    }
    [self setTitleFromDateComponents:components];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    self.selectedDate = [cal dateFromComponents:components];
}

/*
 * Set the value for this button to be the half-hour proceeding the reference date
 */
-(void)setTimeForNextHalfHourFrom:(NSDate *)referenceDate
{
    NSDateComponents *components = [self componentsFromDate:referenceDate];
    
    if ([components minute] < 25) {
        components.minute = 30;
    } else if ([components minute] < 55) {
        components.minute = 00;
        components.hour = components.hour + 1;
    } else {
        components.minute = 30;
        components.hour = components.hour + 1;
    }
    [self setTitleFromDateComponents:components];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    self.selectedDate = [cal dateFromComponents:components];
}

-(void)setTitleFromDateComponents:(NSDateComponents *)components
{
    // Create an 'output' date
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *outputDate = [cal dateFromComponents:components];
    
    //
    // Create a date formatter
    //
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm"];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    //
    // Set the output
    //
    NSString *stringValue = [dateFormatter stringFromDate:outputDate];
    [self setTitle:stringValue forState:UIControlStateNormal];
    [self setTitle:stringValue forState:UIControlStateHighlighted];
}

-(NSDateComponents *)componentsFromDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar components:
            NSTimeZoneCalendarUnit
            | NSYearCalendarUnit
            | NSMonthCalendarUnit
            | NSDayCalendarUnit
            | NSHourCalendarUnit
            | NSMinuteCalendarUnit fromDate:date];
}

- (void)drawCircleButton
{
    self.circleLayer = [CAShapeLayer layer];
    [self.circleLayer setBounds:CGRectMake(0.0f, 0.0f,
                                           [self bounds].size.width,
                                           [self bounds].size.height)];
    [self.circleLayer setPosition:CGPointMake(CGRectGetMidX([self bounds]),CGRectGetMidY([self bounds]))];
    
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    [self.circleLayer setPath:[path CGPath]];
    [self.circleLayer setStrokeColor:self.currentTitleColor.CGColor];
    [self.circleLayer setLineWidth:2.0f];
    [self.circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    [[self layer] insertSublayer:self.circleLayer atIndex:0];
}

- (void)setHighlighted:(BOOL)highlighted
{
    UIColor *color = highlighted ? [UIColor lightGrayColor] : [UIColor clearColor];
    [self.circleLayer setFillColor:color.CGColor];
}
@end