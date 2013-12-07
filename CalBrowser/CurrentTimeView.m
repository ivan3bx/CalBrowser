//
//  CurrentTimeView.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/7/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import "CurrentTimeView.h"

@implementation CurrentTimeView

/*
 * Custom drawing to get a top and bottom 'line' to this container view
 */
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    
    // Set width
    CGContextSetLineWidth(context, 2.0);
    
    // Top
    CGContextMoveToPoint(context, 0,0);
    CGContextAddLineToPoint(context, rect.size.width, 0);
    CGContextStrokePath(context);
    
    // Bottom
    CGContextMoveToPoint(context, 0, rect.origin.y + rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, rect.origin.y + rect.size.height);
    CGContextStrokePath(context);
}

@end
