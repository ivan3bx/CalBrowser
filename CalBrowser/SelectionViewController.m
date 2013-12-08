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
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:now];
    
    NSUInteger hour = [components hour];
    
    NSString *currentTimeBlock;
    NSString *nextTimeBlock;
    
    if (components.minute <= 25) {
        currentTimeBlock = [NSString stringWithFormat:@"%i:00", (int)hour];
        nextTimeBlock    = [NSString stringWithFormat:@"%i:30", (int)hour];
    } else if (components.minute <= 55) {
        currentTimeBlock = [NSString stringWithFormat:@"%i:30", (int)hour];
        nextTimeBlock    = [NSString stringWithFormat:@"%i:00", (int)(hour + 1) % 12];
    } else {
        currentTimeBlock = [NSString stringWithFormat:@"%i:00", (int)(hour + 1) % 12];
        nextTimeBlock    = [NSString stringWithFormat:@"%i:30", (int)(hour + 1) % 12];
    }
    
    //
    // Set current block button titles
    //
    [self.currentTimeBtn setTitle:currentTimeBlock forState:UIControlStateNormal];
    [self.currentTimeBtn setTitle:currentTimeBlock forState:UIControlStateHighlighted];

    //
    // Set next block button titles
    //
    [self.nextTimeBtn setTitle:nextTimeBlock forState:UIControlStateNormal];
    [self.nextTimeBtn setTitle:nextTimeBlock forState:UIControlStateHighlighted];

}
@end
