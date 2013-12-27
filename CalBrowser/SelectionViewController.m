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
#import "CABLEvent.h"
#import "NSDate+Additions.h"

@interface SelectionViewController () <SWRevealViewControllerDelegate> {
    NSTimer *timer;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

@implementation SelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureLocationSidebar];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectStartTime:)
                                                 name:@"didSelectStartTime" object:nil];
}

-(void)didSelectStartTime:(NSNotification *)notification
{
    [self performSegueWithIdentifier:@"calendar" sender:notification];
}

-(void)swapViewsFrom:(UIView *)fromView to:(UIView *)toView
{
    [toView setHidden:NO];

    CGPoint originalCenter = fromView.center;
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         fromView.center = CGPointMake(originalCenter.x,
                                                       originalCenter.y + 400);
                     }
                     completion:^(BOOL finished) {
                         fromView.center = originalCenter;
                         [fromView setHidden:YES];
                     }
     ];
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
    currentItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Meeting"
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
    id dest = segue.destinationViewController;
    if ([dest isKindOfClass:[CalendarsViewController class]]) {
        [(CalendarsViewController *)dest setMeetingStartAt:[sender userInfo][@"startTime"]];
    }
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
//        [self.currentTimeBtn setEnabled:NO];
//        [self.nextTimeBtn setEnabled:NO];
    } else {
        //
        // This view will slide back in
        //
//        [self.currentTimeBtn setEnabled:YES];
//        [self.nextTimeBtn setEnabled:YES];
    }
}

- (BOOL)revealControllerPanGestureShouldBegin:(SWRevealViewController *)revealController
{
    return YES;
//    return !(self.currentTimeBtn.isTouchInside || self.nextTimeBtn.isTouchInside);
}

@end
