//
//  SelectionViewController.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/6/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import "SelectionViewController.h"
#import "CalendarsViewController.h"

@interface SelectionViewController () {
    NSTimer *timer;
    BOOL flashSeparator;
}

@end

@implementation SelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateClocks];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClocks) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.currentTimeBtn drawCircleButton];
    [self.nextTimeBtn drawCircleButton];
}

/*
 * We transitioned from some date/time selection
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CalendarsViewController *dest;
    dest = (CalendarsViewController *)segue.destinationViewController;
    
    if (sender == self.currentTimeBtn) {
        // TODO: Set the date on the destination controller
    } else if (sender == self.nextTimeBtn) {
        // TODO: Set the date on the destination controller
    }
}

- (void)updateClocks
{
    NSDate *now = [NSDate new];
    
    //
    // Update current time
    //
    flashSeparator = !flashSeparator;
    NSString *dateFormat = (flashSeparator) ? @"h:mm" : @"h mm";

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    self.currentTimeLabel.text = [formatter stringFromDate:now];
    
    //
    // Update current / next buttons
    //
    [self.currentTimeBtn setTimeForPreviousHalfHourFrom:now];
    [self.nextTimeBtn setTimeForNextHalfHourFrom:now];
}
@end
