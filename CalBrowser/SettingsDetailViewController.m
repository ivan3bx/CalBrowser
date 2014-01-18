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

@end

@implementation SettingsDetailViewController

-(void)viewDidLoad
{
    _config = [CABLConfig sharedInstance];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender == self.locationCell) {
        //
        // Dismiss the revealView with a delay
        //
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                                (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.revealViewController revealToggleAnimated:NO];
        });
    }
}

-(IBAction)returnToSettingsHome:(UIStoryboardSegue *)segue {
    NSLog(@"Returned to: %@ from: %@", segue.destinationViewController, segue.sourceViewController);
}

-(void)viewWillAppear:(BOOL)animated
{
    self.accountCell.detailTextLabel.text = _config.currentAccount.emailAddress;
    self.locationCell.detailTextLabel.text = _config.currentCity;
}

-(IBAction)dismissAboutModal:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UITableViewDelegate Methods
#pragma mark -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
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
