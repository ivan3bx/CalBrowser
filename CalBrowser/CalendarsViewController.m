//
//  CalendarsViewController.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/1/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import "CalendarsViewController.h"
#import "CABLConfig.h"
#import "NXOAuth2.h"
#import "CABLResourceList.h"
#import "CABLResource.h"

@interface CalendarsViewController ()
@property(nonatomic,readwrite) NSArray *rooms;
@end

@implementation CalendarsViewController

- (void)viewWillAppear:(BOOL)animated
{
    // Start loading a list of calendars
    [CABLResourceList loadResourceList:^(NSArray *data) {
        self.rooms = data;
        [(UITableView *)self.view reloadData];
    } error:^(NSError *error) {
        NSLog(@"Failed to load data, error: %@", error.userInfo);
    }];
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
    
    // Configure the cell...
    CABLResource *entry = self.rooms[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", entry.name];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
