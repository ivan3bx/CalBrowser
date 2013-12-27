//
//  SelectionActionStartViewController.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/26/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClockButton.h"
#import "CABLEvent.h"

@interface SelectionActionStartViewController : UIViewController

@property (weak, nonatomic) IBOutlet ClockButton *currentTimeBtn;
@property (weak, nonatomic) IBOutlet ClockButton *nextTimeBtn;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;

- (IBAction)selectStartTime:(ClockButton *)sender;

@end
