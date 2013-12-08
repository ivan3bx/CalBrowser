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
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:referenceDate];
    NSUInteger hour = [components hour];
    
    NSString *currentTimeBlock;
    
    if (components.minute <= 25) {
        currentTimeBlock = [NSString stringWithFormat:@"%i:00", (int)hour];
    } else if (components.minute <= 55) {
        currentTimeBlock = [NSString stringWithFormat:@"%i:30", (int)hour];
    } else {
        currentTimeBlock = [NSString stringWithFormat:@"%i:00", (int)(hour + 1) % 12];
    }
    
    [self setTitle:currentTimeBlock forState:UIControlStateNormal];
    [self setTitle:currentTimeBlock forState:UIControlStateHighlighted];
}

/*
 * Set the value for this button to be the half-hour proceeding the reference date
 */
-(void)setTimeForNextHalfHourFrom:(NSDate *)referenceDate
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:referenceDate];
    NSUInteger hour = [components hour];
    
    NSString *nextTimeBlock;
    
    if (components.minute <= 25) {
        nextTimeBlock = [NSString stringWithFormat:@"%i:30", (int)hour];
    } else if (components.minute <= 55) {
        nextTimeBlock = [NSString stringWithFormat:@"%i:00", (int)(hour + 1) % 12];
    } else {
        nextTimeBlock = [NSString stringWithFormat:@"%i:30", (int)(hour + 1) % 12];
    }
    
    [self setTitle:nextTimeBlock forState:UIControlStateNormal];
    [self setTitle:nextTimeBlock forState:UIControlStateHighlighted];
}

- (void)drawCircleButton
{
    self.circleLayer = [CAShapeLayer layer];
    
    [self.circleLayer setBounds:CGRectMake(0.0f, 0.0f, [self bounds].size.width,
                                           [self bounds].size.height)];
    [self.circleLayer setPosition:CGPointMake(CGRectGetMidX([self bounds]),CGRectGetMidY([self bounds]))];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    [self.circleLayer setPath:[path CGPath]];
    
    [self.circleLayer setStrokeColor:[self.currentTitleColor CGColor]];
    
    [self.circleLayer setLineWidth:2.0f];
    [self.circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    
    [[self layer] addSublayer:self.circleLayer];
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted)
    {
        [self.circleLayer setFillColor:[UIColor darkGrayColor].CGColor];
    }
    else
    {
        [self.circleLayer setFillColor:[UIColor clearColor].CGColor];
    }
}
@end