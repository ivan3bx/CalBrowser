//
//  SettingsViewController.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/12/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "SettingsViewController.h"
#import "CABLLocations.h"
#import "CABLConfig.h"

@interface SettingsViewController () {
    CABLConfig *_config;
    CABLLocations *_locations;
}
@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	_config = [CABLConfig sharedInstance];
    _locations = [[CABLLocations alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSString *city = _config.currentCity;
    NSString *loc = _config.currentLocation;
    NSNumber *floor = _config.currentFloor;
    
    if ([_locations locationsForCity:city].count == 1) {
        //
        // Simple city has one location
        //
        self.locationLabel.text = city;
    } else {
        //
        // Not so simple ; specify the location
        //
        self.locationLabel.text = [NSString stringWithFormat:@"%@ - (%@-%@)", city, loc, floor];
    }
}

@end
