//
//  CABLLocations.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/9/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <FMDB/FMDatabase.h>
#import "CABLLocations.h"
#import "CABLResource.h"
#import "CABLConfig.h"

@interface CABLLocations() {
    NSString *_locationId;
    NSString *_cityName;
    NSString *_countryName;
}
@end

@implementation CABLLocations

- (id)initWithData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _locationId  = data[@"locationId"];
        _cityName    = data[@"cityName"];
        _countryName = data[@"countryName"];
    }
    return self;
}

-(NSArray *)regions
{
    NSMutableArray *result = [NSMutableArray array];
    FMDatabase *db = [FMDatabase databaseWithPath:[CABLConfig sharedInstance].databasePath];
    if ([db open]) {
        FMResultSet *res = [db executeQuery:@"SELECT distinct(countryName) from locations"];
        while([res next]) {
            [result addObject:[res stringForColumnIndex:0]];
        }
        [db close];
    }
    return result;
}

-(BOOL)save
{
    /*
     *   'resourceId'
     *   'resourceCommonName'
     *   'resourceEmail'
     *   'resourceDescription'
     *   'resourceType'
     */
    FMDatabase *db = [FMDatabase databaseWithPath:[CABLConfig sharedInstance].databasePath];
    if ([db open]) {
        BOOL result = [db executeUpdate:@"INSERT INTO locations \
                       (locationId, cityName, countryName) \
                       VALUES \
                       (:locationId, :cityName, :countryName)" withArgumentsInArray:@[_locationId, _cityName, _countryName]];
        [db close];
        return result;
    }
    return NO;

}

-(NSArray *)citiesForRegion:(NSString *)regionName
{
    NSMutableArray *result = [NSMutableArray array];
    FMDatabase *db = [FMDatabase databaseWithPath:[CABLConfig sharedInstance].databasePath];
    if ([db open]) {
        FMResultSet *res = [db executeQuery:@"SELECT distinct(cityName) FROM locations ORDER BY cityName DESC"];
        while([res next]) {
            [result addObject:[res stringForColumnIndex:0]];
        }
        [db close];
    }
    return result;
}

/*
 * Cities are logical groupings of several locations,
 * such as ajoining buildings.
 */
-(NSArray *)locationsForCity:(NSString *)name
{
    NSMutableArray *result = [NSMutableArray array];
    FMDatabase *db = [FMDatabase databaseWithPath:[CABLConfig sharedInstance].databasePath];
    if ([db open]) {
        FMResultSet *res = [db executeQuery:@"SELECT locationId FROM locations \
                                                WHERE cityName = :cityName\
                                                ORDER BY locationId DESC"];
        while([res next]) {
            [result addObject:[res stringForColumnIndex:0]];
        }
        [db close];
    }
    return result;
}

/*
 * A given location may have a set of floor #'s associated
 */
-(NSArray *)floorNumbersForLocation:(NSString *)location
{
    NSMutableOrderedSet *floorNumbers = [[NSMutableOrderedSet alloc] init];
    
    for (CABLResource *item in [CABLResource findAllByNamePrefix:location]) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@".*?-(\\d+).*"
                                                                               options:0
                                                                                 error:nil];
        NSTextCheckingResult *result = [regex firstMatchInString:item.name
                                                         options:0 range:NSMakeRange(0, item.name.length)];
        NSString *matchedValue = [item.name substringWithRange:[result rangeAtIndex:1]];
        NSNumber *floorNum = [[[NSNumberFormatter alloc] init] numberFromString:matchedValue];
        if (floorNum) {
            [floorNumbers addObject:floorNum];
        }
    }
    return [floorNumbers sortedArrayUsingComparator:^NSComparisonResult(NSNumber *n1, NSNumber *n2) {
        return [n1 compare:n2];
    }];
}

/*
 * This method will construct an optimal array of 'prefixes' to
 * search based on relative size of the location, to guarantee
 * adequate performance.
 *
 * Locations with several floors but few rooms might have fewer
 * search strings.  Locations with few floors but many rooms
 * might have more.
 */
-(NSArray *)searchStringsForCity:(NSString *)cityName location:(NSString *)loc preferredFloors:(NSArray *)floorNumber
{
    return @[];
}


@end
