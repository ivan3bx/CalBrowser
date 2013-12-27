//
//  SelectionActionMeetingViewController.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/26/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CABLEvent.h"

@interface SelectionActionMeetingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *displayMeetingRoom;
@property (weak, nonatomic) IBOutlet UILabel *displayMeetingTime;

- (IBAction)cancelMeeting:(id)sender;

@end
