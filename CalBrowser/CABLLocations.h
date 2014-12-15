//
//  CABLLocations.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/9/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CABLLocations : NSObject

/*
 * An ordered array of regions
 */
-(NSArray *)regions;

-(BOOL)save;

/*
 * Format: ABC1-4CA-Name
 *         [Location]-[Floor#]?[Extra]?-[Resource Name]
 * Rules:
 *  - A city may be configured to have multiple locations
 *  - A location may or may not have secondary prefix specified
 *  - If secondary prefix exists and starts with a number, that
 *    number is presumed to be a floor number.
 */
-(NSArray *)citiesForRegion:(NSString *)regionName;

/*
 * Cities are logical groupings of several locations,
 * such as ajoining buildings.
 */
-(NSArray *)locationsForCity:(NSString *)cityName;

/*
 * A given location may have a set of floor #'s associated
 */
-(NSArray *)floorNumbersForLocation:(NSString *)location;

/*
 * This method will construct an optimal array of 'prefixes' to 
 * search based on relative size of the location, to guarantee
 * adequate performance.
 *
 * Locations with several floors but few rooms might have fewer
 * search strings.  Locations with few floors but many rooms
 * might have more.
 */
-(NSArray *)searchStringsForCity:(NSString *)cityName location:(NSString *)loc preferredFloors:(NSArray *)floorNumber;

@end
