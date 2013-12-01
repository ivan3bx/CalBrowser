//
//  AppDelegate.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 11/28/13.
//  Copyright (c) Ivan Moscoso. All rights reserved.
//

#import "AppDelegate.h"
#import "NXOAuth2.h"

@implementation AppDelegate

+ (void)initialize;
{
    [self registerOAuthClient];
    [self registerUserDefaults];
}

+ (void)registerOAuthClient
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"clientConfig" ofType:@"json"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        @throw [NSException exceptionWithName:@"Missing configuration"
                                       reason:@"Unable to locate 'clientConfig.json' in application directory"
                                     userInfo:nil];
    } else {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error][@"installed"];
        
        if (error || dict == nil) {
            @throw [NSException exceptionWithName:@"Invalid configuration"
                                           reason:@"Invalid 'clientConfig.json'.  Check system settings."
                                         userInfo:nil];
        }
        
        NSString *clientId = dict[@"client_id"];
        NSString *clientSecret = dict[@"client_secret"];
        NSString *authorizationURI = dict[@"auth_uri"];
        NSString *tokenURI = dict[@"token_uri"];
        
        // Ignore whatever's there
        NSString *redirectURI = @"http://localhost/oauth.callback";
        NSSet *scope = [NSSet setWithObjects:@"https://www.googleapis.com/auth/calendar.readonly", nil];
        
        [[NXOAuth2AccountStore sharedStore] setClientID:clientId
                                                 secret:clientSecret
                                                  scope:scope
                                       authorizationURL:[NSURL URLWithString:authorizationURI]
                                               tokenURL:[NSURL URLWithString:tokenURI]
                                            redirectURL:[NSURL URLWithString:redirectURI]
                                         forAccountType:@"Calendar"];
    }
}

+ (void)registerUserDefaults
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"OAuthCredentials" : [NSNumber numberWithBool:NO]}];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

@end
