//
//  RootController.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/1/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "RootNavigationController.h"
#import "CABLConfig.h"
#import "CABLResourceLoader.h"
#import "CABLUser.h"

@interface RootNavigationController () {
    NSTimer *refreshTimer;
}

@end

@implementation RootNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerRefreshAccessToken];
    [self registerFailedToAuthorize];
    [self registerDidAuthorize];
    [self loadResourceData];
}

/*
 * TODO: loading resource data should be moved to a higher-level initialization
 * mechanism (maybe create a queue with init routines that should complete before
 * the root view controller can do its thing
 */
-(void)loadResourceData
{
    CABLResourceLoader *loader = [[CABLResourceLoader alloc] init];
    [loader loadResources:^(NSArray *resources) {
        NSLog(@"Loaded resources");
    } error:^(NSError *error) {
        NSLog(@"Error loading resources");
    }];
}
-(void)forceAuthentication
{
    [[CABLConfig sharedInstance] setCurrentAccount:nil];
    [self performSegueWithIdentifier:@"authorize" sender:self];
}

- (void)timerRefreshAccessToken:(NSTimer *)timer
{
    CABLUser *user = [CABLConfig sharedInstance].currentAccount;
    [user getJSON:@"https://www.googleapis.com/calendar/v3/users/me/settings/timezone"
       parameters:nil
        onSuccess:^(NSDictionary *data) {
            //
            // Update the account & its access token
            //
            [[CABLConfig sharedInstance] setCurrentAccount:user];
        } onError:^(NSError *error) {
            //
            // Display the authenticate view
            //
            [self forceAuthentication];
        }];
}

-(void)registerRefreshAccessToken
{
    NSLog(@"Registering to refresh access token");
    //
    // Invalidate any existing timer
    //
    [refreshTimer invalidate];
    
    NXOAuth2Account *account = [[CABLConfig sharedInstance] currentAccount].account;
    if (!account) {
        NSLog(@"Account not registered");
        return;
    }

    NSLog(@"Token expires at: %@", account.accessToken.expiresAt);
    refreshTimer = [[NSTimer alloc] initWithFireDate:account.accessToken.expiresAt
                                              interval:(kMeetingLengthInMinutes * 60)
                                                target:self
                                              selector:@selector(timerRefreshAccessToken:)
                                              userInfo:nil repeats:NO];
    refreshTimer.tolerance = 5.0;
    
    //
    // Register a new timer
    //
    [[NSRunLoop mainRunLoop] addTimer:refreshTimer forMode:NSDefaultRunLoopMode];
    NSLog(@"Registered to refresh access token at %@", refreshTimer.fireDate);
}

#pragma mark -
#pragma mark NSNotification handling
#pragma mark -

- (void)registerDidAuthorize
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification
                        object:[NXOAuth2AccountStore sharedStore] queue:nil
                    usingBlock:^(NSNotification *notification) {
                        
                        //
                        // Access the account that authorized
                        //
                        NXOAuth2Account *account = notification.userInfo[NXOAuth2AccountStoreNewAccountUserInfoKey];
                        
                        if (account == nil) {
                            // This must be a logout notification
                            return;
                        }
                        
                        //
                        // Register to refresh access token
                        //
                        [self registerRefreshAccessToken];
                        
                        
                        //
                        // Load the user's data
                        //
                        CABLUser *user = [[CABLUser alloc] initWithAccount:account];
                        [user loadInfo:^(CABLUser *success) {
                            //
                            // Save this user
                            //
                            [[CABLConfig sharedInstance] setCurrentAccount:user];

                            //
                            // Load the list of locations before dismissing
                            //
                            CABLResourceLoader *loader = [[CABLResourceLoader alloc] init];
                            [loader loadResources:^(NSArray *resources) {
                                NSLog(@"Loaded resources");
                                [self dismissViewControllerAnimated:YES completion:nil];
                            } error:^(NSError *error) {
                                NSLog(@"Error loading resources");
                                [self dismissViewControllerAnimated:YES completion:nil];
                            }];

                        } onError:^(NSError *error) {
                            NSLog(@"Error on authentication: %@", error);
                        }];
                    }];
}

- (void)registerFailedToAuthorize
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification
                        object:[NXOAuth2AccountStore sharedStore] queue:nil
                    usingBlock:^(NSNotification *notification){
                        //
                        // Access the error
                        //
                        NSError *error = [notification.userInfo objectForKey:NXOAuth2AccountStoreErrorKey];
                        
                        //
                        // Log for now & clear the account
                        //
                        NSLog(@"Failed to authorize with error: %@", error.userInfo);
                        [[CABLConfig sharedInstance] setCurrentAccount:nil];
                    }];
}

@end
