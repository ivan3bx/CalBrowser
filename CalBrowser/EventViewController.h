//
//  EventViewController.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/18/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CABLResource.h"
#import "CABLUser.h"
#import "CABLEvent.h"

@interface EventViewController : UITableViewController

@property (nonatomic) NSDate *start;
@property (nonatomic) NSDate *end;
@property (nonatomic) CABLResource *resource;

- (IBAction)createEvent:(id)sender;

@end
