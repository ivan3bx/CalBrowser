//
//  CABLUser.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/15/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NXOAuth2Client/NXOAuth2.h>

typedef void(^CABLJSONHandler)(NSDictionary *data);
typedef void(^CABLDataHandler)(NSData *data);
typedef void(^CABLErrorHandler)(NSError *error);

@interface CABLUser : NSObject <NSCoding>

@property(nonatomic,readonly) NXOAuth2Account *account;
@property(nonatomic,readonly) NSString *emailAddress;
@property(nonatomic,readonly) NSString *domain;
@property(nonatomic,readonly) NSString *firstName;
@property(nonatomic,readonly) NSString *lastName;
@property(nonatomic,readonly) NSString *primaryCalendarId;

/*
 * Initialization
 */
-(id)initWithAccount:(NXOAuth2Account *)account;
-(void)loadInfo:(void (^)(CABLUser *success))successBlock onError:(void (^)(NSError *error))errorBlock;
-(void)signOut;

/*
 * Authenticated network access
 */
-(void)getJSON:(NSString *)urlString
    parameters:(NSDictionary *)params
     onSuccess:(CABLJSONHandler)onSuccess
       onError:(CABLErrorHandler)onError;

-(void)getXML:(NSString *)urlString
   parameters:(NSDictionary *)params
    onSuccess:(CABLDataHandler)onSuccess
      onError:(CABLErrorHandler)onError;

-(void)postJSON:(NSString *)url
           body:(NSDictionary *)jsonBody
      onSuccess:(CABLJSONHandler)success
        onError:(CABLErrorHandler)error;

-(void)deleteResource:(NSString *)urlString
            onSuccess:(void(^)())onSuccess
              onError:(CABLErrorHandler)onError;

@end
