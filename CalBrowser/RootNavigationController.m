//
//  RootController.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/1/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "RootNavigationController.h"
#import "CABLConfig.h"
#import "CABLResourceList.h"

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
}

- (void)viewDidAppear:(BOOL)animated
{
    NXOAuth2Account *account = [[CABLConfig sharedInstance] currentAccount];
    
    if (account == nil) {
        [self forceAuthentication];
    }

}

-(void)forceAuthentication
{
    [[CABLConfig sharedInstance] setCurrentAccount:nil];
    [self performSegueWithIdentifier:@"authorize" sender:self];
}

- (void)timerRefreshAccessToken:(NSTimer *)timer
{
    NXOAuth2Account *account = [CABLConfig sharedInstance].currentAccount;
    NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/calendar/v3/users/me/settings/timezone"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NXOAuth2Request performMethod:@"GET"
                        onResource:url usingParameters:nil
                       withAccount:account sendProgressHandler:nil
                   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                       if (error) {
                           //
                           // Display the authenticate view
                           //
                           [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                           [self forceAuthentication];
                       } else {
                           //
                           // Update the account & its access token
                           //
                           [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                           [[CABLConfig sharedInstance] setCurrentAccount:account];
                       }
                   }];
}

-(void)registerRefreshAccessToken
{
    NSLog(@"Registering to refresh access token");
    //
    // Invalidate any existing timer
    //
    [refreshTimer invalidate];
    
    NXOAuth2Account *account = [[CABLConfig sharedInstance] currentAccount];
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
                        
                        //
                        // Store the account for later
                        //
                        [CABLConfig sharedInstance].currentAccount = account;
                        
                        //
                        // Register to refresh access token
                        //
                        [self registerRefreshAccessToken];
                        
                        //
                        // Load the list of locations before dismissing
                        //
                        [CABLResourceList loadResourceList:^(NSArray *resources) {
                            NSLog(@"Loaded resources");
                            [self dismissViewControllerAnimated:YES completion:nil];
                        } error:^(NSError *error) {
                            NSLog(@"Error loading resources");
                            [self dismissViewControllerAnimated:YES completion:nil];
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
