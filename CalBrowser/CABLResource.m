//
//  CABLResource.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/3/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
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
        if (!data[@"resourceDescription"]) {
            data = [NSMutableDictionary dictionaryWithDictionary:data];
            ((NSMutableDictionary *)data)[@"resourceDescription"] = @"";
        }
        _data = [data copy];
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

        [db close];
        return result;
    }
    return NO;
}

+(NSUInteger)numberOfEntries
{
    NSUInteger count = 0;
    FMDatabase *db = [FMDatabase databaseWithPath:[CABLConfig sharedInstance].databasePath];
    if ([db open]) {
        FMResultSet *res = [db executeQuery:@"SELECT count(*) FROM resources"];
        if([res next]) {
            count = [res intForColumnIndex:0];
        }
    }
    [db close];
    return count;
}

+(CABLResource *)findByEmail:(NSString *)arg
{
    return [self findByQuery:@"SELECT * from resources WHERE resourceEmail = (?)"
               withCondition:arg].firstObject;
}

+(NSArray *)findAll
{
    return [self findByQuery:@"SELECT * from resources ORDER BY resourceCommonName" withCondition:nil];
}

+(NSArray *)findAllByNamePrefix:(NSString *)arg
{
    arg = [NSString stringWithFormat:@"%@%%", arg];
    return [self findByQuery:@"SELECT * FROM resources WHERE resourceCommonName LIKE (?)"
               withCondition:arg];
}

+(NSArray *)findByQuery:(NSString *)query withCondition:(NSString *)condition
{
    NSMutableArray *result = [NSMutableArray array];
    FMDatabase *db = [FMDatabase databaseWithPath:[CABLConfig sharedInstance].databasePath];
    if ([db open]) {
        FMResultSet *res = [db executeQuery:query, condition];
        while([res next]) {
            NSDictionary *dataArg = @{@"resourceId"         : [res stringForColumn:@"resourceId"],
                                      @"resourceCommonName" : [res stringForColumn:@"resourceCommonName"],
                                      @"resourceEmail"      : [res stringForColumn:@"resourceEmail"],
                                      @"resourceType"       : [res stringForColumn:@"resourceType"]};
            [result addObject:[[CABLResource alloc] initWithData:dataArg]];
        }
        [db close];
    }
    return result;
}

+(NSArray *)reloadWithData:(NSArray *)data
{
    NSMutableArray *savedEntries = [NSMutableArray array];

    [CABLResource reset];
    [data enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        CABLResource *resource = [[CABLResource alloc] initWithData:obj];
        [savedEntries addObject:resource];
        [resource save];
    }];
    return savedEntries;
}

+(void)reset
{
    FMDatabase *db = [FMDatabase databaseWithPath:[CABLConfig sharedInstance].databasePath];
    if ([db open]) {
        BOOL result = [db executeUpdate:@"DELETE from resources"];
        NSAssert(result, @"Failed to clear existing resources");
    }
    [db close];
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
