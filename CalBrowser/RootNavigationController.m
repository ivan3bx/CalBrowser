//
//  RootController.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/1/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import "RootNavigationController.h"
#import "CABLConfig.h"

@interface RootNavigationController ()

@end

@implementation RootNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerFailedToAuthorize];
    [self registerDidAuthorize];
}

- (void)viewDidAppear:(BOOL)animated
{
    NXOAuth2Account *account = [[CABLConfig sharedInstance] currentAccount];
    
    if (account == nil) {
        //
        // Kick off authentication
        //
        [self performSegueWithIdentifier:@"authorize" sender:self];
    }

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
                        // Dismiss the auth controller
                        //
                        [self dismissViewControllerAnimated:YES completion:nil];
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
