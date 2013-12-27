//
//  SelectionActionStartViewController.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/26/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "SelectionActionStartViewController.h"
#import "NSDate+Additions.h"

@interface SelectionActionStartViewController () {
    NSTimer *_timer;
}

@end

@implementation SelectionActionStartViewController

-(void)viewDidLoad
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self
                                            selector:@selector(updateClocks)
                                            userInfo:nil repeats:YES];
    [self updateClocks];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.currentTimeBtn drawCircleButton];
    [self.nextTimeBtn drawCircleButton];

    NSDate *now = [NSDate new];
    NSDate *earliest = [now dateForCurrentHalfHour];
    NSDate *latest   = [now dateForNextHalfHour];
    if ([CABLEvent findEventWithin:earliest and:latest]) {
        [self performSegueWithIdentifier:@"booked" sender:self];
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.startTimeLabel.hidden = YES;
        
        CGRect rect = self.currentTimeBtn.bounds;
        self.currentTimeBtn.bounds = CGRectMake(rect.origin.x,
                                                rect.origin.y,
                                                70, 70);
        
        rect = self.nextTimeBtn.bounds;
        self.nextTimeBtn.bounds = CGRectMake(rect.origin.x,
                                             rect.origin.y,
                                             70, 70);
    } else {
        self.startTimeLabel.hidden = NO;

        CGRect rect = self.currentTimeBtn.bounds;
        self.currentTimeBtn.bounds = CGRectMake(rect.origin.x,
                                                rect.origin.y,
                                                110, 110);
        
        rect = self.nextTimeBtn.bounds;
        self.nextTimeBtn.bounds = CGRectMake(rect.origin.x,
                                             rect.origin.y,
                                             110, 110);
    }
}

- (void)updateClocks
{
    NSDate *now = [NSDate new];

    [self.currentTimeBtn setTimeForPreviousHalfHourFrom:now];
    [self.nextTimeBtn setTimeForNextHalfHourFrom:now];
}

- (IBAction)selectStartTime:(ClockButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectStartTime"
                                                        object:self
                                                      userInfo:@{@"startTime" : sender.selectedDate}];
}

@end
