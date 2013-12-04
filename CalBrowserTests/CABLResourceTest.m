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

@interface CABLResourceTest : XCTestCase

@end

@implementation CABLResourceTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInitAndSave
{
    NSDictionary *data = @{@"resourceId"         : @"foo1",
                           @"resourceCommonName" : @"foo2",
                           @"resourceEmail"      : @"foo3",
                           @"resourceDescription": @"foo4",
                           @"resourceType"       : @"foo5"};
    CABLResource *resource = [[CABLResource alloc] initWithData:data];
    XCTAssertTrue([resource save], @"Expected resource to be saved");
}

@end
