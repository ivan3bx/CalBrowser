//
//  EventViewController.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/18/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "EventViewController.h"
#import "CABLConfig.h"

@interface EventViewController ()

@end

@implementation EventViewController

- (IBAction)createEvent:(id)sender
{
    [sender setEnabled:NO];
    CABLEvent *event = [[CABLEvent alloc] init];
    event.start = self.start;
    event.end = self.end;
    event.meetingRoom = self.resource;
    event.meetingOwner = [CABLConfig sharedInstance].currentAccount;

    //
    // Create the event
    //
    [event pushToServer:^(CABLEvent *theEvent) {
        NSLog(@"Successfully created event: %@", theEvent.eventId);
        [event save];
        [self.navigationController popToRootViewControllerAnimated:YES];
        [sender setEnabled:YES];
    } error:^(NSError *theError) {
        NSLog(@"Error: %@", theError);
        [sender setEnabled:YES];
    }];
}

#pragma mark -
#pragma mark UITableViewDataSource methods
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            // Title and Location
            return 2;
        case 1:
            // Start and End Time
            return 2;
        case 2:
            // TODO: Show a Map?
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CreateCell" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

        NSDateFormatter *format;
        format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"h:mm a";
        
        
        switch (indexPath.section) {
            case 0:
                if (indexPath.row == 0) {
                    cell.textLabel.text = @"Title";
                    cell.detailTextLabel.text = @"Instant Meeting";
                } else {
                    cell.textLabel.text = @"Room";
                    cell.detailTextLabel.text = self.resource.shortName;
                }
                break;
            case 1:
                if (indexPath.row == 0) {
                    cell.textLabel.text = @"Start";
                    cell.detailTextLabel.text = [format stringFromDate:self.start];
                } else {
                    cell.textLabel.text = @"End";
                    cell.detailTextLabel.text = [format stringFromDate:self.end];
                }
                break;
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate methods
#pragma mark -

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

@end
