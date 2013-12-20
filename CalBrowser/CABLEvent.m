//
//  CABLMeeting.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/13/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "CABLEvent.h"
#import "CABLConfig.h"
#import <FMDB/FMDatabase.h>

typedef void(^SuccessHandler)(CABLEvent *event);
typedef void(^ErrorHandler)(NSError *error);

@interface CABLEvent() {
}
@end

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

-(id)initWithPersistedEventId:(NSString *)eventId
{
    self = [super init];
    if (self) {
        [self loadDataWithEventId:eventId];
    }
    return self;
}

-(void)pushToServer:(void (^)(CABLEvent *theEvent))onSuccess error:(void (^)(NSError *theError))onError
{
    NSDateFormatter *format;
    format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";

    NSDictionary *body = @{ @"attendees" : @[@{@"email" : self.meetingRoom.email}],
                            @"start"     : @{@"dateTime" : [format stringFromDate:self.start]},
                            @"end"       : @{@"dateTime" : [format stringFromDate:self.end]},
                            @"location"  : self.meetingRoom.name,
                            @"summary"   : @"Instant Meeting!"};

    NSString *calendarId = self.meetingOwner.primaryCalendarId;
    NSString *url = [NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events", calendarId];
    
    [self.meetingOwner postJSON:url
                           body:body onSuccess:^(NSDictionary *data) {
                               //
                               // Handle successful push
                               //
                               [self parseResponse:data];
                               onSuccess(self);
                           } onError:^(NSError *error) {
                               //
                               // Handle errors
                               //
                               onError(error);
                           }
     ];
}

-(void)updateFromServer:(void (^)(CABLEvent *theEvent))onSuccess error:(void (^)(NSError *theError))onError
{
    NSString *calendarId = self.meetingOwner.primaryCalendarId;
    NSString *url = [NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events/%@", calendarId, self.eventId];
    [self.meetingOwner getJSON:url parameters:@{@"fields" : @"attendees(email,responseStatus),status,updated"}
                     onSuccess:^(NSDictionary *data) {
                         [self parseTimestampsFromResponse:data];
                         [self parseStatusFromResponse:data];
                         onSuccess(self);
                     } onError:^(NSError *error) {
                         onError(error);
                     }
     ];
}

-(BOOL)save
{
    FMDatabase *db = [FMDatabase databaseWithPath:[CABLConfig sharedInstance].databasePath];
    db.logsErrors = YES;
    
    if ([db open]) {
        NSString *updateQuery = @"INSERT INTO events \
                                  (eventId, createdAt, updatedAt, \
                                   title, ownerEmail, \
                                   roomEmail, start, end) \
                                  VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        BOOL result = [db executeUpdate:updateQuery
                   withArgumentsInArray:@[self.eventId, self.createdAt, self.updatedAt,
                                          self.title, self.meetingOwner.emailAddress,
                                          self.meetingRoom.email, self.start, self.end]];
        [db close];
        return result;
    }
    return NO;
}

-(BOOL)remove
{
    FMDatabase *db = [FMDatabase databaseWithPath:[CABLConfig sharedInstance].databasePath];
    db.logsErrors = YES;
    
    if ([db open]) {
        NSString *deleteQuery = @"DELETE FROM events WHERE eventId = ?";
        BOOL result = [db executeUpdate:deleteQuery withArgumentsInArray:@[self.eventId]];
        [db close];
        return result;
    }
    return NO;
}

+(CABLEvent *)findEventStartingAt:(NSDate *)startDate
{
    CABLEvent *eventResponse;
    FMDatabase *db = [FMDatabase databaseWithPath:[CABLConfig sharedInstance].databasePath];
    if ([db open]) {
        NSString *query = @"SELECT eventId from events WHERE start = (?)";
        FMResultSet *res = [db executeQuery:query, startDate];

        if([res next]) {
            NSString *eventId = [res stringForColumn:@"eventId"];
            eventResponse = [[CABLEvent alloc] initWithPersistedEventId:eventId];
        }
        [db close];
    }
    return eventResponse;
}

-(void)cancelOnServer:(void (^)(CABLEvent *theEvent))onSuccess error:(void (^)(NSError *theError))onError
{
    NSString *calendarId = self.meetingOwner.primaryCalendarId;
    NSString *urlString = [NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events/%@",
                           calendarId, self.eventId];

    [self.meetingOwner deleteResource:urlString
                            onSuccess:^ {
                                FMDatabase *db = [FMDatabase databaseWithPath:[CABLConfig sharedInstance].databasePath];
                                db.logsErrors = YES;
                                [self remove];
                                onSuccess(self);
                            } onError:^(NSError *error) {
                                onError(error);
                            }
     ];

}

-(void)loadDataWithEventId:(NSString *)theId
{
    FMDatabase *db = [FMDatabase databaseWithPath:[CABLConfig sharedInstance].databasePath];
    db.logsErrors = YES;
    
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"SELECT eventId, createdAt, updatedAt, \
                                                    title, ownerEmail, \
                                                    roomEmail, start, end \
                                                    FROM events WHERE eventId = ?", theId];
        if ([rs next]) {
            _eventId = [rs stringForColumnIndex:0];
            _createdAt = [rs dateForColumnIndex:1];
            _updatedAt = [rs dateForColumnIndex:2];
            _title = [rs stringForColumnIndex:3];
            _meetingOwner = [[CABLConfig sharedInstance] currentAccount];
            _meetingRoom = [CABLResource findByEmail:[rs stringForColumnIndex:5]];
            _start = [rs dateForColumnIndex:6];
            _end = [rs dateForColumnIndex:7];
            
        }
        [db close];
    }
}

-(void)parseResponse:(NSDictionary *)data
{
    _eventId   = data[@"id"];
    _title     = data[@"summary"];
    
    [self parseTimestampsFromResponse:data];
    [self parseStatusFromResponse:data];
}

-(void)parseTimestampsFromResponse:(NSDictionary *)data
{
    NSDateFormatter *format;
    format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";
    
    if (data[@"created"]) {
        _createdAt = [format dateFromString:data[@"created"]];
    }
    
    if (data[@"updated"]) {
        _updatedAt = [format dateFromString:data[@"updated"]];
    }
}

-(void)parseStatusFromResponse:(NSDictionary *)data
{
    NSDictionary *attendeeData;
    for (NSDictionary *obj in data[@"attendees"]) {
        if ([obj[@"email"] isEqualToString:self.meetingRoom.email]) {
            attendeeData = obj;
        }
    }

    NSString *attendeeStatus = attendeeData[@"responseStatus"];
    NSString *eventStatus = data[@"status"];
    

    if ([attendeeStatus isEqualToString:@"needsAction"]) {
        // Pending if the room hasn't accepted
        _status = ResponsePending;
    } else if ([attendeeStatus isEqualToString:@"declined"]) {
        // Declined if the room declined
        _status = ResponseDeclined;
    } else if ([attendeeStatus isEqualToString:@"accepted"]) {
        // Accepted if the room accepted
        _status = ResponseAccepted;
    } else if ([eventStatus isEqualToString:@"cancelled"]) {
        // Canceled if the user deleted this meeting
        _status = ResponseCanceled;
    } else {
        _status = ResponseUnknown;
    }
}

@end
