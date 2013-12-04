//
//  CABLResource.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/3/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import <FMDB/FMDatabase.h>
#import "CABLResource.h"
#import "CABLConfig.h"

@interface CABLResource() {
    NSDictionary *_data;
}
@end

@implementation CABLResource

-(id)initWithData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _data = data;
    }
    return self;
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
        BOOL result = [db executeUpdate:@"INSERT INTO resources \
                       (resourceId, resourceCommonName, resourceEmail, \
                        resourceDescription, resourceType) \
                       VALUES \
                       (:resourceId, :resourceCommonName, :resourceEmail, \
                        :resourceDescription, :resourceType)" withParameterDictionary:_data];
        NSLog(@"Did do something? %i", result);

        [db close];
        return result;
    }
    return NO;
}

+(CABLResource *)findByEmail:(NSString *)arg
{
    CABLResource *result;
    FMDatabase *db = [FMDatabase databaseWithPath:[CABLConfig sharedInstance].databasePath];
    if ([db open]) {
        FMResultSet *res = [db executeQuery:@"SELECT \
                            (resourceId, resourceCommonName, resourceEmail, \
                             resourceDescription, resourceType) \
                            FROM resources \
                            WHERE resourceEmail = (?)", arg];
        if([res next]) {
            NSDictionary *dataArg = @{@"resourceId"         : [res stringForColumn:@"resourceId"],
                                      @"resourceCommonName" : [res stringForColumn:@"resourceCommonName"],
                                      @"resourceEmail"      : [res stringForColumn:@"resourceEmail"],
                                      @"resourceDescription": [res stringForColumn:@"resourceDescription"],
                                      @"resourceType"       : [res stringForColumn:@"resourceType"]};
            result = [[CABLResource alloc] initWithData:dataArg];
        }
        [db close];
    }
    return result;
}

+(NSArray *)findAllByNamePrefix:(NSString *)arg
{
    NSMutableArray *result = [NSMutableArray array];
    FMDatabase *db = [FMDatabase databaseWithPath:[CABLConfig sharedInstance].databasePath];
    if ([db open]) {
        FMResultSet *res = [db executeQuery:@"SELECT \
                            (resourceId, resourceCommonName, resourceEmail, \
                            resourceDescription, resourceType) \
                            FROM resources \
                            WHERE resourceCommonName LIKE (?)", arg];
        while([res next]) {
            NSDictionary *dataArg = @{@"resourceId"         : [res stringForColumn:@"resourceId"],
                                      @"resourceCommonName" : [res stringForColumn:@"resourceCommonName"],
                                      @"resourceEmail"      : [res stringForColumn:@"resourceEmail"],
                                      @"resourceDescription": [res stringForColumn:@"resourceDescription"],
                                      @"resourceType"       : [res stringForColumn:@"resourceType"]};
            [result addObject:[[CABLResource alloc] initWithData:dataArg]];
        }
        [db close];
    }
    return result;
}

+(NSArray *)reloadWithData:(NSArray *)data
{
    return nil;
}



#pragma mark -
#pragma mark Data accessors
#pragma mark -

-(NSString *)internalID
{
    return _data[@"resourceId"];
}

-(NSString *)email
{
    return _data[@"resourceEmail"];
}

-(NSString *)name
{
    return _data[@"resourceCommonName"];
}

-(NSString *)optionalDescription
{
    return _data[@"resourceDescription"];
}

-(NSString *)resourceType
{
    return _data[@"resourceType"];
}

@end
