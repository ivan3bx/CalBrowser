//
//  CABLResourceListTest.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/2/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "CABLResourceList.h"

@interface CABLResourceListTest : XCTestCase {
    CABLResourceList *list;
    NSData *data;
}

@end

@implementation CABLResourceListTest

- (void)setUp
{
    [super setUp];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"resource_input" ofType:@"xml"];
    data = [NSData dataWithContentsOfFile:path];
    list = [[CABLResourceList alloc] initWithData:data];
}

- (void)testEmptyList
{
    list = [[CABLResourceList alloc] initWithData:nil];
    XCTAssertEqual(0U, list.count);
}

- (void)testResourceListInitialization
{
    XCTAssertTrue(list.count == 2, @"Expected two entries in the list");
}

- (void)testResourceProperties
{
    NSDictionary *item = [list resourceForIndex:0];
    XCTAssertEqualObjects(@"6761618511", item[@"resourceId"]);
    XCTAssertEqualObjects(@"ABC-3 Meeting Room-A1", item[@"resourceCommonName"]);
    XCTAssertEqualObjects(@"example.com_ABC@resource.calendar.google.com", item[@"resourceEmail"]);
    XCTAssertEqualObjects(@"A nice description", item[@"resourceDescription"]);
    XCTAssertEqualObjects(@"Conference Room", item[@"resourceType"]);
}

- (void)testResourcesAreOrdered
{
    XCTAssertEqualObjects(@"ABC-3 Meeting Room-A1", [list resourceForIndex:0][@"resourceCommonName"]);
    XCTAssertEqualObjects(@"DEF-4 Meeting Room-B1", [list resourceForIndex:1][@"resourceCommonName"]);
}

@end
