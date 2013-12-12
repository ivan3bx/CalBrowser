//
//  SelectionViewController.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/6/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <SWRevealViewController/SWRevealViewController.h>
#import "SelectionViewController.h"
#import "CalendarsViewController.h"
#import "CABLConfig.h"

@interface SelectionViewController () <SWRevealViewControllerDelegate> {
    NSTimer *timer;
    BOOL flashSeparator;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

@implementation SelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateClocks];
    [self configureLocationSidebar];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                           selector:@selector(updateClocks)
                                           userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.currentTimeBtn setEnabled:YES];
    [self.currentTimeBtn drawCircleButton];

    [self.nextTimeBtn setEnabled:YES];
    [self.nextTimeBtn drawCircleButton];
    
    [self.locationNameLabel setText:[CABLConfig sharedInstance].currentCity];
}

- (void)configureLocationSidebar
{
    //
    // Hack up a '<' to hint at the settings screen
    // (see http://stackoverflow.com/questions/4260238/draw-custom-back-button-on-iphone-navigation-bar)
    //
    UINavigationItem *previousItem = [[UINavigationItem alloc] initWithTitle:@""];
    
    //
    // The 'current item' is the navigation item for THIS view.
    // Because we're taking over whatever was configured in the storyboard,
    // This needs to allocate the backbar button & its title.
    UINavigationItem *currentItem = [[UINavigationItem alloc] initWithTitle:self.navigationItem.title];
    currentItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Set Time"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self.navigationController
                                                                    action:@selector(popViewControllerAnimated:)];
    //
    // Override the items & order on the navbar
    //
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setItems:@[previousItem, currentItem] animated:NO];
    
    //
    // Intercept push/pop situations
    //
    [navigationBar setDelegate:self];

    //
    // Set the gesture
    //
    if (self.revealViewController.panGestureRecognizer) {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    self.revealViewController.delegate = self;
}

/*
 * We transitioned from some date/time selection
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CalendarsViewController *dest;
    dest = (CalendarsViewController *)segue.destinationViewController;
    
    if (sender == self.currentTimeBtn) {
        [dest setMeetingStartAt:self.currentTimeBtn.selectedDate];
    } else if (sender == self.nextTimeBtn) {
        [dest setMeetingStartAt:self.currentTimeBtn.selectedDate];
    }
}

- (void)updateClocks
{
    NSDate *now = [NSDate new];
    
    //
    // Update current time
    //
    flashSeparator = !flashSeparator;
    NSString *dateFormat = (flashSeparator) ? @"h:mm" : @"h mm";

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    self.currentTimeLabel.text = [formatter stringFromDate:now];
    
    //
    // Update current / next buttons
    //
    [self.currentTimeBtn setTimeForPreviousHalfHourFrom:now];
    [self.nextTimeBtn setTimeForNextHalfHourFrom:now];
}

#pragma mark -
#pragma mark UINavigationBarDelegate methods
#pragma mark -

/*
 * We are popping a custom navigation item, so we need to intercept
 * an attempt to pop this, reject it but transition the 'reveal' anyway
 */
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    if ([item.title isEqualToString:self.navigationItem.title]) {
        [self.revealViewController revealToggleAnimated:YES];
        return NO;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        return YES;
    }
}

#pragma mark -
#pragma mark SWRevealViewControllerDelegate methods
#pragma mark -

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    if (position == FrontViewPositionRight) {
        //
        // This view will slide out
        //
        [self.currentTimeBtn setEnabled:NO];
        [self.nextTimeBtn setEnabled:NO];
    } else {
        //
        // This view will slide back in
        //
        [self.currentTimeBtn setEnabled:YES];
        [self.nextTimeBtn setEnabled:YES];
        [self.locationNameLabel setText:[CABLConfig sharedInstance].currentCity];
    }
}

- (BOOL)revealControllerPanGestureShouldBegin:(SWRevealViewController *)revealController
{
    return !(self.currentTimeBtn.isTouchInside || self.nextTimeBtn.isTouchInside);
}

@end
