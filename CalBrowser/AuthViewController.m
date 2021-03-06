//
//  AuthViewController.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 11/30/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "AuthViewController.h"
#import "NXOAuth2.h"
#import "CABLConfig.h"

@interface AuthViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation AuthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:@"Calendar"
                                   withPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
                                       [self.webView loadRequest:[NSURLRequest requestWithURL:preparedURL]];
                                   }];
}

#pragma mark -
#pragma mark UIWebViewDelegate methods
#pragma mark -

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL isAuthRedirect = [[NXOAuth2AccountStore sharedStore] handleRedirectURL:request.URL];
    if (isAuthRedirect) {
        [webView setHidden:YES];
    }
    return !isAuthRedirect;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // User cancelled
    if (error.code == NSURLErrorCancelled) return;
    
    // 'WebKitErrorFrameLoadInterruptedByPolicyChange' (102)
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"]) return;
}

@end
