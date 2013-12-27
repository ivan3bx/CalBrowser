//
//  CABLEventTest.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/26/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "CABLModelTest.h"

@interface CABLEventTest : CABLModelTest {
    CABLEvent *event;
}
@end

@implementation CABLEventTest

- (void)setUp
{
    [super setUp];
    event = [[CABLEvent alloc] initWithOwner:super.mockUser
                                    resource:super.mockResource
                                  startingAt:[self dateFor:@"09:30"]
                                    endingAt:[self dateFor:@"10:00"]];
    event.eventId = @"1:EventId";
    event.title   = @"1:Title";
    
    XCTAssert([event save]);
}

- (void)tearDown
{
    [super tearDownWith:@"DELETE FROM events WHERE eventId LIKE '1:%'"];
}

-(void)testFindForStart
{
    CABLEvent *found = [CABLEvent findEventStartingAt:[super dateFor:@"09:30"]];
    XCTAssert([found.start isEqualToDate:event.start],
              @"Expected event to be found for exact start date");

}

-(void)testFindEventWithinStart
{
    XCTAssertNotNil([CABLEvent findEventWithin:[super dateFor:@"09:29"]
                                           and:[super dateFor:@"09:30"]],
                    @"Expected event when start within range");

    XCTAssertNotNil([CABLEvent findEventWithin:[super dateFor:@"09:29"]
                                           and:[super dateFor:@"09:31"]],
                    @"Expected event when start within range");

    XCTAssertNotNil([CABLEvent findEventWithin:[super dateFor:@"09:30"]
                                           and:[super dateFor:@"09:31"]],
                    @"Expected event when start within range");
}

-(void)testFindEventWithinEnd
{
    XCTAssertNotNil([CABLEvent findEventWithin:[super dateFor:@"09:31"]
                                           and:[super dateFor:@"10:00"]],
                    @"Expected event when start within range");

    XCTAssertNotNil([CABLEvent findEventWithin:[super dateFor:@"09:59"]
                                           and:[super dateFor:@"10:01"]],
                    @"Expected event when start within range");

    XCTAssertNotNil([CABLEvent findEventWithin:[super dateFor:@"10:00"]
                                           and:[super dateFor:@"10:01"]],
                    @"Expected event when start within range");
}

-(void)testFindEventWithinOutOfRange
{
    XCTAssertNil([CABLEvent findEventWithin:[super dateFor:@"09:00"]
                                        and:[super dateFor:@"09:29"]],
                 @"Expected event when start within range");
    XCTAssertNil([CABLEvent findEventWithin:[super dateFor:@"10:01"]
                                        and:[super dateFor:@"10:01"]],
                 @"Expected event when start within range");

}

@end
