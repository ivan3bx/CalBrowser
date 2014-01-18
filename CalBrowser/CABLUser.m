//
//  CABLUser.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/15/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "CABLUser.h"
@interface CABLUser() {
    CABLDataHandler  _dataHandler;
    CABLErrorHandler _errorHandler;
    CABLJSONHandler  _jsonHandler;
    NSMutableData *_data;
}

@end

@implementation CABLUser

-(id)initWithAccount:(NXOAuth2Account *)account
{
    self = [super init];
    if (self) {
        _account = account;
    }
    return self;
}

-(void)loadInfo:(void (^)(CABLUser *success))successBlock onError:(void (^)(NSError *error))errorBlock
{
    
    [self getJSON:@"https://www.googleapis.com/plus/v1/people/me"
       parameters:nil
        onSuccess:^(NSDictionary *data) {
            //
            // Set basic attributes
            //
            NSArray *emails = data[@"emails"];
            _emailAddress = emails.firstObject[@"value"];
            _domain = data[@"domain"];
            _firstName = data[@"name"][@"givenName"];
            _lastName = data[@"name"][@"familyName"];
            
            //
            // Set our primary calendar ID
            //
            NSDictionary *params = @{@"minAccessRole" : @"owner",
                                     @"fields"        : @"items(id,primary)"};
            [self getJSON:@"https://www.googleapis.com/calendar/v3/users/me/calendarList"
               parameters:params
                onSuccess:^(NSDictionary *response) {
                    NSArray *items = response[@"items"];
                    
                    for (NSDictionary *item in items) {
                        if (item[@"primary"] != nil) {
                            _primaryCalendarId = item[@"id"];
                        }
                    }
                    successBlock(self);
                } onError:^(NSError *error) {
                    errorBlock(error);
                }];
        } onError:^(NSError *error) {
            errorBlock(error);
        }
     ];
}


-(void)getJSON:(NSString *)urlString
    parameters:(NSDictionary *)params
     onSuccess:(CABLJSONHandler)onSuccess
       onError:(CABLErrorHandler)onError
{
    NSURL *url = [NSURL URLWithString:urlString];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NXOAuth2Request performMethod:@"GET" onResource:url usingParameters:params
                       withAccount:_account sendProgressHandler:nil
                   responseHandler:^(NSURLResponse *rsp, NSData *data, NSError *error) {
                       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                       if (!error) {
                           //
                           // Parse JSON and return response
                           //
                           NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                                options:NSJSONReadingAllowFragments
                                                                                  error:&error];
                           if (!error) {
                               onSuccess(dict);
                           } else {
                               onError(error);
                           }
                       } else {
                           //
                           // Response was an error
                           //
                           NSLog(@"Error loading URL: %@", url);
                           onError(error);
                       }
               }];

}

-(void)getXML:(NSString *)urlString
   parameters:(NSDictionary *)params
    onSuccess:(CABLDataHandler)onSuccess
      onError:(CABLErrorHandler)onError
{
    NXOAuth2Request *signedReq;
    signedReq = [[NXOAuth2Request alloc] initWithResource:[NSURL URLWithString:urlString]
                                                   method:@"GET"
                                               parameters:nil];
    //
    // Associate current user's account with this request
    //
    signedReq.account = _account;

    //
    // Append content-type (since this API is XML)
    //
    NSMutableURLRequest *xmlRequest = [signedReq.signedURLRequest mutableCopy];
    [xmlRequest addValue:@"application/atom+xml" forHTTPHeaderField:@"Content-type"];

    //
    // Start to process this request
    //
    _dataHandler  = onSuccess;
    _errorHandler = onError;
    _data = nil;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection connectionWithRequest:xmlRequest delegate:self];
}

-(void)postJSON:(NSString *)urlString
           body:(NSDictionary *)jsonBody
      onSuccess:(CABLJSONHandler)onSuccess
        onError:(CABLErrorHandler)onError
{
    //
    // Prepare the body
    //
    NSError *error;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonBody options:0 error:&error];
    if (error) {
        return onError(error);
    }
    
    //
    // Construct the signed request
    //
    NXOAuth2Request *originalRequest;
    NSMutableURLRequest *signedRequest;
    
    originalRequest =  [[NXOAuth2Request alloc] initWithResource:[NSURL URLWithString:urlString]
                                                          method:@"POST" parameters:nil];
    originalRequest.account = _account;
    signedRequest = [[originalRequest signedURLRequest] mutableCopy];
    [signedRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [signedRequest setHTTPBody:bodyData];
    [signedRequest setTimeoutInterval:30.0];

    //
    // Start to process this request
    //
    _dataHandler = nil;
    _jsonHandler = onSuccess;
    _errorHandler = onError;
    _data = nil;

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection connectionWithRequest:signedRequest delegate:self];
}

-(void)deleteResource:(NSString *)urlString
            onSuccess:(void(^)())onSuccess
              onError:(CABLErrorHandler)onError
{
    NSURL *url = [NSURL URLWithString:urlString];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NXOAuth2Request performMethod:@"DELETE" onResource:url usingParameters:nil
                       withAccount:_account sendProgressHandler:nil
                   responseHandler:^(NSURLResponse *rsp, NSData *data, NSError *error) {
                       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                       if (!error) {
                           onSuccess();
                       } else {
                           NSLog(@"Error loading URL: %@", url);
                           onError(error);
                       }
                   }
     ];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate methods
#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    if (response.statusCode != 200) {
        NSDictionary *dict = @{@"statusCode" : [NSNumber numberWithInt:(int)response.statusCode],
                               @"message"    : @"Calendar resource list failed to load any data"};
        _errorHandler([NSError errorWithDomain:@"CalBrowser" code:1 userInfo:dict]);

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [connection cancel];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (_data == nil) {
        _data = [NSMutableData dataWithData:data];
    } else {
        [_data appendData:data];
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (_dataHandler) {
        _dataHandler([_data copy]);
    }

    if (_jsonHandler) {
        NSError *error;
        NSDictionary *results;
        results = [NSJSONSerialization JSONObjectWithData:_data
                                                  options:NSJSONReadingAllowFragments
                                                    error:&error];
        if (!error) {
            _jsonHandler(results);
        } else {
            _errorHandler(error);
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error loading connection: %@", error);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    _errorHandler(error);
}

#pragma mark -
#pragma mark NSCoder methods
#pragma mark -

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_primaryCalendarId forKey:@"primaryCalendarId"];
    [aCoder encodeObject:_emailAddress forKey:@"emailAddress"];
    [aCoder encodeObject:_firstName forKey:@"firstName"];
    [aCoder encodeObject:_lastName forKey:@"lastName"];
    [aCoder encodeObject:_account forKey:@"account"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _primaryCalendarId = [[aDecoder decodeObjectForKey:@"primaryCalendarId"] copy];
        _emailAddress      = [[aDecoder decodeObjectForKey:@"emailAddress"] copy];
        _firstName         = [[aDecoder decodeObjectForKey:@"firstName"] copy];
        _lastName          = [[aDecoder decodeObjectForKey:@"lastName"] copy];
        _account           = [aDecoder decodeObjectForKey:@"account"];
    }
    return self;
}

@end
