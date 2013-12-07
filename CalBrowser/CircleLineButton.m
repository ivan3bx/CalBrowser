//
//  CircleLineButton.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/6/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import "CircleLineButton.h"

@interface CircleLineButton ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@end

@implementation CircleLineButton

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