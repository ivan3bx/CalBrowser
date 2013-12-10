//
//  LocationsControllerViewController.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/9/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CABLLocations.h"

@interface LocationsControllerViewController : UITableViewController
@property (nonatomic,readonly) CABLLocations *locations;
@end
