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
    NSDictionary *cities;
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
        cities = domainConfig[@"cities"];
    }
    return self;
}

-(NSArray *)cityNames
{
    NSMutableArray *names = [[NSMutableArray alloc] init];
    [cities enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSArray *locations, BOOL *stop) {
        [names addObject:name];
    }];
    return names;
}

/*
 * Cities are logical groupings of several locations,
 * such as ajoining buildings.
 */
-(NSArray *)locationsForCity:(NSString *)name
{
    return [cities[name] copy];
}

/*
 * A given location may have a set of floor #'s associated
 */
-(NSSet *)floorNumbersForLocation:(NSString *)location
{
    NSMutableSet *floorNumbers = [[NSMutableSet alloc] init];
    
    for (CABLResource *item in [CABLResource findAllByNamePrefix:location]) {
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@".*?-(\\d+).*"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
    }
    return floorNumbers;
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
