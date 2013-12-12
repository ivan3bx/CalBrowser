//
//  FloorsViewController.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/12/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "FloorsViewController.h"
#import "CABLLocations.h"
#import "CABLConfig.h"

@interface FloorsViewController () {
    CABLLocations *_locations;
    CABLConfig *_config;
}

@end

@implementation FloorsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _locations = [[CABLLocations alloc] init];
    _config = [CABLConfig sharedInstance];
}

#pragma mark -
#pragma mark UITableViewDataSource methods
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_locations floorNumbersForLocation:_config.currentLocation].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    
    NSString *loc = _config.currentLocation;
    NSArray *floors = [_locations floorNumbersForLocation:loc];
    cell.textLabel.text = [NSString stringWithFormat:@"Floor: %@", floors[indexPath.row]];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate methods
#pragma mark -

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *loc = _config.currentLocation;
    NSArray *floors = [_locations floorNumbersForLocation:loc];
    NSNumber *selectedFloor = floors[indexPath.row];

    [CABLConfig sharedInstance].currentFloor = selectedFloor;
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
