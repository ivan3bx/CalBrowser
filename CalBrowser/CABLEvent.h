//
//  CABLMeeting.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/13/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CABLResource.h"
#import "CABLUser.h"

typedef NS_ENUM(NSUInteger, EventResponseStatus) {
    ResponsePending,
    ResponseDeclined,
    ResponseAccepted,
    ResponseCanceled,
    ResponseUnknown
};

@interface CABLEvent : NSObject

#pragma mark - Request attributes

@property (nonatomic) CABLUser     *meetingOwner;
@property (nonatomic) CABLResource *meetingRoom;
@property (nonatomic) NSDate       *start;
@property (nonatomic) NSDate       *end;

#pragma mark - Response attributes

@property (nonatomic, readonly) NSString *eventId;
@property (nonatomic, readonly) NSDate   *createdAt;
@property (nonatomic, readonly) NSDate   *updatedAt;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *location;
@property (nonatomic, readonly) enum EventResponseStatus status;

#pragma mark - Initialization methods

-(id)initWithOwner:(CABLUser *)owner resource:(CABLResource *)resource
             startingAt:(NSDate *)start endingAt:(NSDate *)end;

-(id)initWithPersistedEventId:(NSString *)eventId;

#pragma mark - Pushing to and updating from the server

-(void)pushToServer:(void (^)(CABLEvent *theEvent))onSuccess
              error:(void (^)(NSError *theError))onError;

-(void)updateFromServer:(void (^)(CABLEvent *theEvent))onSuccess
                  error:(void (^)(NSError *theError))onError;

-(void)cancelOnServer:(void (^)(CABLEvent *theEvent))onSuccess
                error:(void (^)(NSError *theError))onError;

#pragma mark - Persisting to the local database

-(BOOL)save;
-(BOOL)remove;

#pragma mark - Querying the local database

+(CABLEvent *)findEventStartingAt:(NSDate *)startDate;

@end
