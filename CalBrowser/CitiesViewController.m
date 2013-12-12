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

@interface CitiesViewController ()

@end

@implementation CitiesViewController

- (void)awakeFromNib
{
    _locations = [[CABLLocations alloc] init];
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
    NSString *regionName = [CABLConfig sharedInstance].currentRegion;
    NSString *cityName   = [CABLConfig sharedInstance].currentCity;
    NSIndexPath *path = [NSIndexPath indexPathForRow:[[self.locations citiesForRegion:regionName] indexOfObject:cityName]
                                           inSection:[[self.locations regions] indexOfObject:regionName]];
    [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

- (NSString *)cityNameForRegion:(NSString *)region atIndex:(NSUInteger)index
{
    return [self.locations citiesForRegion:region][index];
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

    NSString *region = self.locations.regions[indexPath.section];
    NSString *cityName = [self cityNameForRegion:region
                                         atIndex:indexPath.row];
    BOOL isMultiLocation = [self.locations locationsForCity:cityName].count > 1;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                            forIndexPath:indexPath];
    cell.textLabel.text = cityName;

    if (isMultiLocation) {
        NSString *value =  [NSString stringWithFormat:@"%i locations",
                            [self.locations locationsForCity:cityName].count];
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *region = self.locations.regions[indexPath.section];
    NSString *cityName = [self cityNameForRegion:region atIndex:indexPath.row];
    [[CABLConfig sharedInstance] setCurrentCity:cityName];
    
    if ([self isMultiLocation:[tableView cellForRowAtIndexPath:indexPath]]) {
        [[CABLConfig sharedInstance] setCurrentLocation:@"UNDEFINED"]; // We will segue to location selector
        [[CABLConfig sharedInstance] setCurrentFloor:nil];
    } else {
        [[CABLConfig sharedInstance] setCurrentLocation:[[self.locations locationsForCity:cityName] firstObject]];
        [[CABLConfig sharedInstance] setCurrentFloor:nil];
    }
    return indexPath;
}

#pragma mark -
#pragma mark UIViewController methods
#pragma mark -

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(UITableViewCell *)sender
{
    if ([self isMultiLocation:sender]) {
        return YES;
    } else {
        // Presume we have one location and should use it
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
}

-(BOOL)isMultiLocation:(UITableViewCell *)cell
{
    NSString *region = self.locations.regions[[self.tableView indexPathForCell:cell].section];
    NSString *cityName = [self cityNameForRegion:region
                                         atIndex:[self.tableView indexPathForCell:cell].row];
    return [self.locations locationsForCity:cityName].count > 1;

}
@end
