//
//  CABLResourceTest.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/3/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CABLConfig.h"
#import "CABLResource.h"

@interface CABLResourceTest : XCTestCase {
    CABLResource *resource1;
    CABLResource *resource2;
}

@end

@implementation CABLResourceTest

- (void)setUp
{
    [super setUp];
    NSMutableDictionary *data =
    data = [NSMutableDictionary dictionaryWithDictionary:@{@"resourceId"         : @"foo1",
                                                           @"resourceCommonName" : @"foo2",
                                                           @"resourceEmail"      : @"foo@email.com",
                                                           @"resourceDescription": @"foo4",
                                                           @"resourceType"       : @"foo5"}];
    resource1 = [[CABLResource alloc] initWithData:data];

    data[@"resourceCommonName"] = @"bar2";
    data[@"resourceEmail"] = @"bar@email.com";
    resource2 = [[CABLResource alloc] initWithData:data];
}

- (void)tearDown
{
    [super tearDown];
    [CABLResource reset];
}

- (void)testSave
{
    XCTAssertTrue([resource1 save], @"Expected resource to be saved");
    XCTAssertEqual(1U, [CABLResource numberOfEntries]);
}

- (void)testFindAllByPrefix
{
    XCTAssertTrue([resource1 save]);
    XCTAssertTrue([resource2 save]);
    NSArray *arr = [CABLResource findAllByNamePrefix:@"f"];
    XCTAssertEqual(1U, arr.count, @"Expected to find one resource by prefix");
}

- (void)testFindByEmail
{
    XCTAssertTrue([resource1 save]);
    CABLResource *testInstance = [CABLResource findByEmail:@"foo@email.com"];
    XCTAssertEqualObjects(@"foo2", testInstance.name, @"Expected to find a resource by email address");
}

- (void)testFindAll
{
    XCTAssertTrue([resource1 save]);
    XCTAssertTrue([resource2 save]);
    XCTAssertTrue([CABLResource findAll].count > 0, @"Expected results when finding all");
}

@end
