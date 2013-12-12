//
//  CalendarsViewController.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/1/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "CalendarsViewController.h"
#import "CABLConfig.h"
#import "NXOAuth2.h"
#import "CABLResourceList.h"
#import "CABLResource.h"
#import "CABLFreeList.h"

@interface CalendarsViewController ()
@property(nonatomic,readwrite) NSArray *rooms;
@property(nonatomic,readwrite) NSDate *startTime;
@property(nonatomic,readwrite) NSDate *endTime;

@end

@implementation CalendarsViewController

- (void)viewWillAppear:(BOOL)animated
{
    // Start loading list of available rooms
    CABLFreeList *freeList = [[CABLFreeList alloc] initWithRange:self.startTime
                                                          ending:self.endTime];
    [freeList load:^(CABLFreeList *freeList) {
        //
        // Block responds to an instance with data
        //
        self.rooms = freeList.freeResources;
        [(UITableView *)self.view reloadData];
    } error:^(NSError *error) {
        //
        // Handle network or data errors
        //
        NSLog(@"Failed to load data, error: %@", error.userInfo);
    }];
}

-(void)setMeetingStartAt:(NSDate *)startTime
{
    self.startTime = startTime;
    self.endTime   = [startTime dateByAddingTimeInterval:(kMeetingLengthInMinutes * 60)];
}

#pragma mark -
#pragma mark - UITableViewDataSource methods
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rooms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    CABLResource *entry = self.rooms[indexPath.row];
    
    // Strip out the location
    NSString *loc = [CABLConfig sharedInstance].currentLocation;
    cell.textLabel.text = [entry.name substringFromIndex:[entry.name rangeOfString:loc].length + 1];
    return cell;
}

@end
