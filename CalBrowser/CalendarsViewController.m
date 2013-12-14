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
#import "CABLResourceLoader.h"
#import "CABLResource.h"
#import "CABLFreeList.h"

@interface CalendarsViewController () {
    CABLConfig *_config;
}

@property(nonatomic,readwrite) NSArray *rooms;
@property(nonatomic,readwrite) NSDate *startTime;
@property(nonatomic,readwrite) NSDate *endTime;

@end

@implementation CalendarsViewController

-(void)viewDidLoad
{
    _config = [CABLConfig sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated
{
    //
    // Set the title
    //
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"h:mm";
    
    NSString *title = [NSString stringWithFormat:@"%@-%@",
                       [format stringFromDate:self.startTime],
                       [format stringFromDate:self.endTime]];
    self.navigationItem.title = title;
    
    //
    // Start loading list of available rooms
    //
    CABLFreeList *freeList = [[CABLFreeList alloc] initWithRange:self.startTime
                                                          ending:self.endTime];
    [freeList load:^(CABLFreeList *freeList) {
        //
        // Block responds to an instance with data
        //
        self.rooms = freeList.freeResources;
        [self.tableView reloadData];
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
    NSString *loc = [NSString stringWithFormat:@"%@-", _config.currentLocation];
    NSRange range = [entry.name rangeOfString:loc];
    cell.textLabel.text = [entry.name substringFromIndex:range.length];
    return cell;
}

@end
