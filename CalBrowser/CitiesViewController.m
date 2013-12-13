//
//  LocationsControllerViewController.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/9/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <SWRevealViewController/SWRevealViewController.h>
#import "CitiesViewController.h"
#import "CABLLocations.h"
#import "CABLResource.h"
#import "CABLConfig.h"

@interface CitiesViewController () {
    CABLConfig *_config;
}

@end

@implementation CitiesViewController

- (void)awakeFromNib
{
    _locations = [[CABLLocations alloc] init];
    _config = [CABLConfig sharedInstance];
}

- (void)viewDidLoad
{
    //
    // Configure the UITableView behavior
    //
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.navigationItem.rightBarButtonItem = nil;
    
    //
    // Select the current city
    //
    NSString *regionName = _config.currentRegion;
    NSString *cityName   = _config.currentCity;
    NSIndexPath *path = [NSIndexPath indexPathForRow:[[self.locations citiesForRegion:regionName] indexOfObject:cityName]
                                           inSection:[[self.locations regions] indexOfObject:regionName]];
    [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark -
#pragma mark UITableViewDataSource methods
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.locations.regions.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *regionName = self.locations.regions[section];
    return [self.locations citiesForRegion:regionName].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.locations.regions[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                            forIndexPath:indexPath];

    NSString *cityName = [self cityForIndexPath:indexPath];
    cell.textLabel.text = cityName;

    if ([self isMultiLocationForPath:indexPath]) {
        NSString *value =  [NSString stringWithFormat:@"%lu locations",
                            (unsigned long)[self.locations locationsForCity:cityName].count];
        cell.detailTextLabel.text = value;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate methods
#pragma mark -

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cityName        = [self cityForIndexPath:indexPath];
    NSString *defaultLocation = [self locationsForIndexPath:indexPath].firstObject;

    _config.currentCity       = cityName;
    _config.currentLocation   = defaultLocation;
    _config.currentFloor      = nil;

    return indexPath;
}

#pragma mark -
#pragma mark UIViewController methods
#pragma mark -

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(UITableViewCell *)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if ([self isMultiLocationForPath:indexPath] || [self isMultiFloorSingleLocationForPath:indexPath]) {
        //
        // Do we need to proceed forward?
        //
        return YES;
    } else {
        //
        // Presume we have one location and floor, and we should use it
        //
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
}


-(BOOL)isMultiLocationForPath:(NSIndexPath *)indexPath
{
    return [self locationsForIndexPath:indexPath].count > 1;
}

-(BOOL)isMultiFloorSingleLocationForPath:(NSIndexPath *)indexPath
{
    NSArray *locations = [self locationsForIndexPath:indexPath];
    NSArray *firstLocationFloors = [self.locations floorNumbersForLocation:locations.firstObject];

    return locations.count == 1 && firstLocationFloors.count > 1;
}

-(NSString *)regionForIndexPath:(NSIndexPath *)indexPath
{
    return self.locations.regions[indexPath.section];
}

-(NSString *)cityForIndexPath:(NSIndexPath *)indexPath
{
    return [self.locations citiesForRegion:[self regionForIndexPath:indexPath]][indexPath.row];
}

-(NSArray *)locationsForIndexPath:(NSIndexPath *)indexPath
{
    return [self.locations locationsForCity:[self cityForIndexPath:indexPath]];
}

@end
