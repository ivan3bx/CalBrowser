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

enum ResponseStatus {
    needsAction = 0,
    declined    = 1,
    tentative   = 2,
    accepted    = 3
};

@interface CABLEvent : NSObject

@property (nonatomic) CABLUser     *meetingOwner;
@property (nonatomic) CABLResource *meetingRoom;
@property (nonatomic) NSDate       *start;
@property (nonatomic) NSDate       *end;

@property (nonatomic, readonly) NSString *eventId;
@property (nonatomic, readonly) NSDate   *createdAt;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) enum ResponseStatus status;

-(id)initWithOwner:(CABLUser *)owner resource:(CABLResource *)resource
             startingAt:(NSDate *)start endingAt:(NSDate *)end;

-(void)save:(void (^)(CABLEvent *))onSuccess error:(void (^)(NSError *))onError;

@end
