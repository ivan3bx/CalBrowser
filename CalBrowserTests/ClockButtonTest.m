//
//  ClockButtonTest.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/8/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ClockButton.h"

@interface ClockButtonTest : XCTestCase {
    ClockButton *button;
}

@end

@implementation ClockButtonTest

- (void)setUp
{
    [super setUp];
    button = [[ClockButton alloc] init];
}

/*
 * Date param must match "hh:mm"
 */
- (NSDate *)at:(NSString *)timeString
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"HH:mm:ss";
    return [format dateFromString:[NSString stringWithFormat:@"%@:00", timeString]];
}

- (void)testPreviousShowsHourMark_MinutesBetween_00_25
{
    [@[@"00:00", @"00:01", @"00:24"] enumerateObjectsUsingBlock:^(NSString *testValue, NSUInteger idx, BOOL *stop) {
        [button setTimeForPreviousHalfHourFrom:[self at:testValue]];
        XCTAssertEqualObjects(@"12:00", button.currentTitle);
    }];
}
- (void)testPreviousShowsHalfHourMark_MinutesBetween_25_and_54
{
    [@[@"00:25", @"00:30", @"00:54"] enumerateObjectsUsingBlock:^(NSString *testValue, NSUInteger idx, BOOL *stop) {
        [button setTimeForPreviousHalfHourFrom:[self at:testValue]];
        XCTAssertEqualObjects(@"12:30", button.currentTitle);
    }];
}

- (void)testPreviousShowsNextHourMark_MinutesBetween_55_and_59
{
    [@[@"00:55", @"00:59", @"01:00"] enumerateObjectsUsingBlock:^(NSString *testValue, NSUInteger idx, BOOL *stop) {
        [button setTimeForPreviousHalfHourFrom:[self at:testValue]];
        XCTAssertEqualObjects(@"1:00", button.currentTitle);
    }];
}

- (void)testPreviousRespectsNoon
{
    [button setTimeForPreviousHalfHourFrom:[self at:@"12:59"]];
    XCTAssertEqualObjects(@"1:00", button.currentTitle);
    NSLog(@"Date from 12:59 -> %@", button.selectedDate);

    [button setTimeForPreviousHalfHourFrom:[self at:@"23:59"]];
    XCTAssertEqualObjects(@"12:00", button.currentTitle);
    NSLog(@"Date from 23:59 -> %@", button.selectedDate);
}


- (void)testNextShowsHalfHourMark_MinutesBetween_00_25
{
    [@[@"00:00", @"00:01", @"00:24"] enumerateObjectsUsingBlock:^(NSString *testValue, NSUInteger idx, BOOL *stop) {
        [button setTimeForNextHalfHourFrom:[self at:testValue]];
        XCTAssertEqualObjects(@"12:30", button.currentTitle);
    }];
}
- (void)testNextShowsNextHourMark_MinutesBetween_25_and_54
{
    [@[@"00:25", @"00:30", @"00:54"] enumerateObjectsUsingBlock:^(NSString *testValue, NSUInteger idx, BOOL *stop) {
        [button setTimeForNextHalfHourFrom:[self at:testValue]];
        XCTAssertEqualObjects(@"1:00", button.currentTitle);
    }];
}

- (void)testNextShowsNextNextHourMark_MinutesBetween_55_and_59
{
    [@[@"00:55", @"00:59", @"01:00"] enumerateObjectsUsingBlock:^(NSString *testValue, NSUInteger idx, BOOL *stop) {
        [button setTimeForNextHalfHourFrom:[self at:testValue]];
        XCTAssertEqualObjects(@"1:30", button.currentTitle);
    }];
}

@end
