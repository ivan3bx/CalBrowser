//
//  CABLResourceListTest.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/2/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "CABLResourceLoader.h"
#import "CABLModelTest.h"

@interface CABLResourceLoaderTest : CABLModelTest {
    CABLResourceLoader *list;
    NSData *data;
}

@end

@implementation CABLResourceLoaderTest

- (void)setUp
{
    [super setUp];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"resource_input" ofType:@"xml"];
    
    data = [NSData dataWithContentsOfFile:path];
    list = [[CABLResourceLoader alloc] initWithData:data];
}

-(void)tearDown
{
    [super tearDownWith:@"DELETE from resources"];
}

- (void)testEmptyList
{
    list = [[CABLResourceLoader alloc] initWithData:nil];
    [list loadResources:^(NSArray *resources) {
        XCTAssertEqual((NSUInteger)0, resources.count);
    } error:^(NSError *error) {
        XCTFail(@"Expected loadResources to return empty results");
    }];
}

- (void)testResourceListInitialization
{
    [list loadResources:^(NSArray *resources) {
        XCTAssertTrue(resources.count == 2, @"Expected two entries in the list");
    } error:^(NSError *error) {
        XCTFail(@"Expected loadResources to return results");
    }];
}

- (void)testResourceProperties
{
    [list loadResources:^(NSArray *resources) {
        CABLResource *item = [resources objectAtIndex:0];
        XCTAssertEqualObjects(@"6761618511", item.internalID);
    } error:^(NSError *error) {
        XCTFail(@"Expected loadResources to return results");
    }];
}

- (void)testResourcesAreOrdered
{
    __block CABLResource *item;

    [list loadResources:^(NSArray *resources) {
        item = [resources objectAtIndex:0];
        XCTAssertEqualObjects(@"ABC-3 Meeting Room-A1", item.name);

        item = [resources objectAtIndex:1];
        XCTAssertEqualObjects(@"DEF-4 Meeting Room-B1", item.name);
    } error:^(NSError *error) {
        XCTFail(@"Expected loadResources to return results");
    }];
}

@end
