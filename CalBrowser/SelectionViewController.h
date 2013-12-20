//
//  SelectionViewController.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/6/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClockButton.h"
#import "CurrentTimeView.h"

@interface SelectionViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;

//
// Subview & components for selecting a time
//
@property (weak, nonatomic) IBOutlet UIView *selectTimeSubview;
@property (weak, nonatomic) IBOutlet ClockButton *currentTimeBtn;
@property (weak, nonatomic) IBOutlet ClockButton *nextTimeBtn;

//
// Subview & components for displaying a meeting
@property (weak, nonatomic) IBOutlet UIView *displayMeetingSubview;
@property (weak, nonatomic) IBOutlet UILabel *displayMeetingRoom;
@property (weak, nonatomic) IBOutlet UILabel *displayMeetingTime;
- (IBAction)cancelMeeting:(id)sender;

@end
