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

//-(void)swapViewsFrom:(UIView *)fromView to:(UIView *)toView
//{
//    [toView setHidden:NO];
//
//    CGPoint originalCenter = fromView.center;
//    [UIView animateWithDuration:0.5
//                          delay:0.1
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         fromView.center = CGPointMake(originalCenter.x,
//                                                       originalCenter.y + 400);
//                     }
//                     completion:^(BOOL finished) {
//                         fromView.center = originalCenter;
//                         [fromView setHidden:YES];
//                     }
//     ];
//}

- (void)configureLocationSidebar
{
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
#pragma mark SWRevealViewControllerDelegate methods
#pragma mark -

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    if (position == FrontViewPositionRight) {
        //
        // This view will slide out
        //
        self.bottomView.userInteractionEnabled = NO;
    } else {
        //
        // This view will slide back in
        //
        self.bottomView.userInteractionEnabled = YES;
    }
}

- (IBAction)showPreferences:(UIBarButtonItem *)sender
{
    [self.revealViewController revealToggleAnimated:YES];
}

@end
