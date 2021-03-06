//
//  CABLLocations.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/9/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "CABLLocations.h"
#import "CABLResource.h"
#import "CABLConfig.h"

@interface CABLLocations() {
    NSDictionary *_locationData;
    NSDictionary *_locationsByCity;
    NSArray *_regionNames;
}
@end

@implementation CABLLocations

- (id)init
{
    self = [super init];
    if (self) {
        NSError *error;
        NSString *path             = [CABLConfig sharedInstance].appsDomainConfigPath;
        NSData *configData         = [NSData dataWithContentsOfFile:path];
        NSDictionary *domainConfig = [NSJSONSerialization JSONObjectWithData:configData
                                                                     options:NSJSONReadingAllowFragments
                                                                       error:&error];
        _locationData = domainConfig[@"regions"];
        _regionNames  = domainConfig[@"regionSort"];
    }
    return self;
}

-(NSArray *)regions
{
    return _regionNames;
}

-(NSArray *)citiesForRegion:(NSString *)regionName
{
    NSArray *result;
    if (regionName) {
        NSArray *allCityNames = [_locationData[regionName] allKeys];
        result = [allCityNames sortedArrayUsingComparator:^NSComparisonResult(NSString *s1, NSString *s2) {
            return [s1 compare:s2];
        }];
    }
    return result;
}

/*
 * Cities are logical groupings of several locations,
 * such as ajoining buildings.
 */
-(NSArray *)locationsForCity:(NSString *)name
{
    if (_locationsByCity == nil) {
        NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
        for (NSString *regionName in [_locationData allKeys]) {
            NSDictionary *allCitiesInRegion = _locationData[regionName];
            [allCitiesInRegion enumerateKeysAndObjectsUsingBlock:^(NSString *cityName, NSArray *locations, BOOL *stop) {
                results[cityName] = locations;
            }];
        }
        _locationsByCity = results;
    }
    return _locationsByCity[name];
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
