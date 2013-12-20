//
//  RoomTickerView.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/20/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 * Display string components on a ticket, across the screen
 */
@interface RoomTickerView : UIView

@property (nonatomic,readonly) UIScrollView *scrollView;
@property (nonatomic,readonly) UILabel *contents;

/*
 * The individual components (NSStrings) that make up the scroll contents
 */
@property (nonatomic) NSArray *components;

@end
