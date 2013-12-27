//
//  SelectionClockViewController.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/26/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "SelectionClockViewController.h"
#import "CABLConfig.h"

@interface SelectionClockViewController () {
    BOOL             _flashSeparator;
    NSTimer         *_timer;
    NSDateFormatter *_formatWithSeparator;
    NSDateFormatter *_formatWithOutSeparator;
}

@end

@implementation SelectionClockViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateClocks];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                            selector:@selector(updateClocks)
                                            userInfo:nil repeats:YES];

    _formatWithSeparator = [[NSDateFormatter alloc] init];
    [_formatWithSeparator setDateFormat:@"h:mm"];
    
    _formatWithOutSeparator = [[NSDateFormatter alloc] init];
    [_formatWithOutSeparator setDateFormat:@"h mm"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.locationNameLabel setText:[CABLConfig sharedInstance].currentCity];
    [self updateClocks];
}

- (void)updateClocks
{
    NSDateFormatter *format;
    NSDate *now = [NSDate new];
    
    _flashSeparator = !_flashSeparator;

    format = (_flashSeparator) ? _formatWithSeparator : _formatWithOutSeparator;
    self.currentTimeLabel.text = [format stringFromDate:now];
}

@end
