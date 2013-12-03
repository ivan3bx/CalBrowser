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
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification
                        object:[NXOAuth2AccountStore sharedStore] queue:nil
                    usingBlock:^(NSNotification *notification){
                        NXOAuth2Account *account = notification.userInfo[NXOAuth2AccountStoreNewAccountUserInfoKey];
                        [self didAuthorize:account];
                    }];
    
    [center addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification
                        object:[NXOAuth2AccountStore sharedStore] queue:nil
                    usingBlock:^(NSNotification *notification){
                        NSError *error = [notification.userInfo objectForKey:NXOAuth2AccountStoreErrorKey];
                        [self didFailToAuthorizeWithError:error];
                    }];
}

- (void)didAuthorize:(NXOAuth2Account *)account
{
    [CABLConfig sharedInstance].currentAccount = account;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didFailToAuthorizeWithError:(NSError *)error
{
    NSLog(@"Failed to authorize user");
}

- (void)viewDidAppear:(BOOL)animated
{
    NXOAuth2Account *account = [CABLConfig sharedInstance].currentAccount;
    
    if (account == nil) {
        [self performSegueWithIdentifier:@"authorize" sender:self];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
