//
//  CABLModelTest.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/26/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CABLModelTest.h"

@implementation CABLModelTest

- (void)setUp
{
    [super setUp];
}

-(void)tearDownWith:(NSString *)query
{
    FMDatabase *db = [FMDatabase databaseWithPath:[CABLConfig sharedInstance].databasePath];
    db.logsErrors = YES;
    
    if ([db open]) {
        [db executeUpdate:query];
        [db close];
    }
}

-(NSDate *)dateFor:(NSString *)timeString
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd HH:mmZZZZZ";
    return [format dateFromString:[NSString stringWithFormat:@"2012-11-12 %@-06:00", timeString]];
}

-(CABLUser *)mockUser
{
    id user = [OCMockObject mockForClass:[CABLUser class]];
    [[[user stub] andReturn:@"test+owner@example.com"] emailAddress];
    return user;
}

-(CABLResource *)mockResource
{
    NSMutableDictionary *data =
    data = [NSMutableDictionary dictionaryWithDictionary:@{@"resourceId"         : @"foo1",
                                                           @"resourceCommonName" : @"LOC-2-Room Name-Extra Info",
                                                           @"resourceEmail"      : @"foo@email.com",
                                                           @"resourceDescription": @"foo4",
                                                           @"resourceType"       : @"foo5"}];
    CABLResource *res = [[CABLResource alloc] initWithData:data];
    return res;
}

@end
