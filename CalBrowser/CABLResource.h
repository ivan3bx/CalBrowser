//
//  CABLResource.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/3/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CABLResource : NSObject

@property(nonatomic,readonly) NSString *email;
@property(nonatomic,readonly) NSString *internalID;
@property(nonatomic,readonly) NSString *name;
@property(nonatomic,readonly) NSString *optionalDescription;
@property(nonatomic,readonly) NSString *resourceType;

/*
 * Initializer takes a dictionary of raw data
 * mapping to entries in the Google Calendar API feed:
 *   'resourceId'
 *   'resourceCommonName'
 *   'resourceEmail'
 *   'resourceDescription'
 *   'resourceType'
 */
-(id)initWithData:(NSDictionary *)data;

/*
 * Saves the current instances in the repository
 */
-(BOOL)save;

+(void)reset;

/*
 * Count of all resources in the repository
 */
+(NSUInteger)numberOfEntries;

/*
 * Finds a specific resource by its email identifier
 */
+(CABLResource *)findByEmail:(NSString *)arg;

/*
 * All resources
 */
+(NSArray *)findAll;

/*
 * Find all resources matching the same 'name' prefix
 */
+(NSArray *)findAllByNamePrefix:(NSString *)arg;

/*
 * Reloads the entire contents from the given data
 * replacing any existing data in the repository with this set
 *
 * Arg: an array of NSDict instances (see 'initWithData:')
 * Ret: an array of CABLResource objects
 */
+(NSArray *)reloadWithData:(NSArray *)data;

@end
