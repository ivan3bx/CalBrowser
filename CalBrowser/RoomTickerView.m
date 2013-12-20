//
//  RoomTickerView.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/20/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "RoomTickerView.h"

@interface RoomTickerView() <UIScrollViewDelegate>

@end

@implementation RoomTickerView

-(void)awakeFromNib
{
    [self setup];
}

-(void)setup
{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [_scrollView setDelegate:self];
    _contents   = [[UILabel alloc] initWithFrame:self.bounds];
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-UltraLightItalic" size:24];
    _contents.font = font;
    _contents.textColor = [UIColor colorWithRed:0.211 green:0.729 blue:0.874 alpha:1.0];
    [_scrollView addSubview:_contents];
    [self addSubview:_scrollView];
}


-(void)setComponents:(NSArray *)components
{
    _components = components;
    NSMutableString *str = [[NSMutableString alloc] init];
    
    for (NSString *part in components) {
        [str appendFormat:@"%@             ", part];
    }
    
    _contents.text = str;
    [self.contents sizeToFit];
    self.scrollView.contentSize = CGSizeMake(self.contents.frame.size.width * 1.5,
                                             self.contents.frame.size.height);
    
    //
    // Animation
    //

    CABasicAnimation *scrollText;
    CGFloat fromVal = fmaxf(self.contents.bounds.size.width, 600);

    scrollText=[CABasicAnimation animationWithKeyPath:@"position.x"];
    scrollText.duration = fromVal / 30;
    scrollText.repeatCount = HUGE_VALF;
    scrollText.autoreverses = NO;
    
    
    scrollText.fromValue = [NSNumber numberWithFloat:fromVal];
    scrollText.toValue = [NSNumber numberWithFloat:-340.0];
    
    [[_contents layer] addAnimation:scrollText forKey:@"scrollTextKey"];
}

@end
