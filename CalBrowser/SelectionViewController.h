//
//  SelectionViewController.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/6/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleLineButton.h"

@interface SelectionViewController : UIViewController
@property (weak, nonatomic) IBOutlet CircleLineButton *currentTimeBtn;
@property (weak, nonatomic) IBOutlet CircleLineButton *nextTimeBtn;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *currentTimeView;

@end
