//
//  CircleLineButton.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/6/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleLineButton : UIButton

/*
 * Draws the button's contents
 */
-(void)drawCircleButton;

/*
 * Set the value to be the time closest/preceeding reference date
 */
-(void)setTimeForPreviousHalfHourFrom:(NSDate *)referenceDate;

/*
 * Set the value to be the time proceeding the reference date
 */
-(void)setTimeForNextHalfHourFrom:(NSDate *)referenceDate;
@end
