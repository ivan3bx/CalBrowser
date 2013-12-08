//
//  SelectionViewController.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/6/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClockButton.h"
#import "CurrentTimeView.h"

@interface SelectionViewController : UIViewController
@property (weak, nonatomic) IBOutlet ClockButton *currentTimeBtn;
@property (weak, nonatomic) IBOutlet ClockButton *nextTimeBtn;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;

@end
