//
//  CABLModelTest.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/26/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <FMDB/FMDatabase.h>
#import <OCMock/OCMock.h>

#import "CABLConfig.h"
#import "CABLEvent.h"
#import "CABLUser.h"
#import "CABLResource.h"

@interface CABLModelTest : XCTestCase

@property(nonatomic,readonly)CABLUser     *mockUser;
@property(nonatomic,readonly)CABLResource *mockResource;

-(void)tearDownWith:(NSString *)query;
-(NSDate *)dateFor:(NSString *)timeString;

@end
