//
//  SettingsDetailViewController.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 1/12/14.
//  Copyright (c) 2014 Ivan Moscoso. All rights reserved.
//

#import <SWRevealViewController/SWRevealViewController.h>
#import "CABLConfig.h"
#import "SettingsDetailViewController.h"

@interface SettingsDetailViewController() {
    CABLConfig *_config;
}
@property (weak, nonatomic) IBOutlet UITableViewCell *accountCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *locationCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *instructionsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *versionCell;

@end

@implementation SettingsDetailViewController

-(void)viewDidLoad
{
    _config = [CABLConfig sharedInstance];
    
    UIView *darkGrayView = [[UIView alloc] init];
    darkGrayView.backgroundColor = [UIColor darkGrayColor];

    self.instructionsCell.selectedBackgroundView = darkGrayView;
    self.accountCell.selectedBackgroundView = darkGrayView;
    self.locationCell.selectedBackgroundView = darkGrayView;
}

-(IBAction)returnToSettingsHome:(UIStoryboardSegue *)segue {
    NSLog(@"Returned to: %@ from: %@", segue.destinationViewController, segue.sourceViewController);
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.accountCell.detailTextLabel.text = _config.currentAccount.emailAddress;
    self.locationCell.detailTextLabel.text = _config.currentCity;
}

- (IBAction)signOut:(id)sender
{
    NSLog(@"Implement sign-out");
}

#pragma mark -
#pragma mark UITableViewDelegate Methods
#pragma mark -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if (selectedCell == self.versionCell) {
        return NO;
    }
    return YES;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
    label.textColor = [UIColor whiteColor];
    switch (section) {
        case 0:
            label.text = @"   ACCOUNT INFORMATION";
            break;
        case 1:
            label.text = @"   HELP";
            break;
        default:
            break;
    }
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

@end
