//
//  CABLMeeting.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/13/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "CABLEvent.h"

@implementation CABLEvent

-(id)initWithOwner:(CABLUser *)owner resource:(CABLResource *)resource
        startingAt:(NSDate *)start endingAt:(NSDate *)end
{
    self = [super init];
    if (self) {
        self.meetingOwner = owner;
        self.meetingRoom  = resource;
        self.start        = start;
        self.end          = end;
    }
    return self;
}

-(void)save:(void (^)(CABLEvent *))onSuccess error:(void (^)(NSError *))onError
{
    
}

@end
