//
//  SelectionActionMeetingViewController.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/26/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "SelectionActionMeetingViewController.h"
#import "NSDate+Additions.h"

@interface SelectionActionMeetingViewController () {
    NSDateFormatter *_format;
}
@property (nonatomic) CABLEvent *event;
@property (nonatomic, readonly) NSDateFormatter *format;
@end

@implementation SelectionActionMeetingViewController

-(void)viewWillAppear:(BOOL)animated
{
    self.displayMeetingRoom.text = self.event.meetingRoom.shortName;

    self.displayMeetingTime.text = [NSString stringWithFormat:@"%@ - %@",
                                    [self.format stringFromDate:self.event.start],
                                    [self.format stringFromDate:self.event.end]];
}

-(CABLEvent *)event
{
    if (_event == nil) {
        NSDate *now = [NSDate new];
        NSDate *earliest = [now dateForCurrentHalfHour];
        NSDate *latest   = [now dateForNextHalfHour];
        _event = [CABLEvent findEventWithin:earliest and:latest];
    }
    return _event;
}

-(NSDateFormatter *)format
{
    if (_format == nil) {
        _format = [[NSDateFormatter alloc] init];
        [_format setDateFormat:@"h:mm"];
        [_format setLocale:[NSLocale currentLocale]];
    }
    return _format;
}

- (IBAction)cancelMeeting:(id)sender
{
    [self.event cancelOnServer:^(CABLEvent *theEvent) {
        [theEvent remove];
        [self.navigationController popViewControllerAnimated:YES];
        NSLog(@"Removed meeting!");
    } error:^(NSError *theError) {
        NSLog(@"Error removing meeting: %@", theError);
    }];
}

@end
