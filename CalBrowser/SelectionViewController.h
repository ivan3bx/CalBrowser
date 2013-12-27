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

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

- (IBAction)showPreferences:(id)sender;

@end
