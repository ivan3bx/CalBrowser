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

@interface CalendarsViewController ()

@end

@implementation CalendarsViewController

- (void)viewWillAppear:(BOOL)animated
{
    // Start loading a list of calendars
    [CABLResourceList loadResourceList:^(CABLResourceList *data) {
        NSLog(@"Successfully loaded some data: %@", data);
    } error:^(NSError *error) {
        NSLog(@"Failed to load data, error: %@", error.userInfo);
    }];
    
//    NSString *baseURL   = @"https://apps-apis.google.com/a/feeds/calendar/resource/2.0";
//    NSString *appDomain = [CABLConfig sharedInstance].appsDomain;
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/", baseURL, appDomain]];
//    
//    NXOAuth2Request *authReq = [[NXOAuth2Request alloc] initWithResource:url method:@"GET" parameters:nil];
//    authReq.account = [CABLConfig sharedInstance].currentAccount;
//    
//    NSURLRequest *req = authReq.signedURLRequest;
//    NSMutableURLRequest *mut = [req mutableCopy];
//    [mut addValue:@"application/atom+xml" forHTTPHeaderField:@"Content-type"];
//    
//    [NSURLConnection sendAsynchronousRequest:mut
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        NSLog(@"Received response:: %@, Error: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], connectionError.userInfo);
//        
//    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"Foo on you: %i", indexPath.row];
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
