//
//  LocationsViewController.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/12/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "LocationsViewController.h"
#import "CABLConfig.h"

@interface LocationsViewController ()
@property(nonatomic)NSString *cityName;
@property(nonatomic)CABLLocations *locations;
@end

@implementation LocationsViewController

-(void)viewDidLoad
{
    _cityName = [CABLConfig sharedInstance].currentCity;
    _locations = [[CABLLocations alloc] init];
    self.navigationItem.rightBarButtonItem = nil;
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
    return [self.locations locationsForCity:self.cityName].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self.locations locationsForCity:self.cityName][indexPath.row];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate methods
#pragma mark -
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *location = [self.locations locationsForCity:self.cityName][indexPath.row];
    [CABLConfig sharedInstance].currentLocation = location;
    if ([self isMultiFloor:[tableView cellForRowAtIndexPath:indexPath]]) {
        [CABLConfig sharedInstance].currentFloor = nil;
    } else {
        [CABLConfig sharedInstance].currentFloor = [self.locations floorNumbersForLocation:location][0];
    }
    
    return indexPath;
}

#pragma mark -
#pragma mark UIViewController methods
#pragma mark -

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(UITableViewCell *)sender
{
    if ([self isMultiFloor:sender]) {
        return YES;
    } else {
        // Presume we have one floor and should use it
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
}

-(BOOL)isMultiFloor:(UITableViewCell *)cell
{
    NSUInteger indexOfLocation = [self.tableView indexPathForCell:cell].row;
    NSString *location = [self.locations locationsForCity:self.cityName][indexOfLocation];
    return [self.locations floorNumbersForLocation:location].count > 1;
}

@end
