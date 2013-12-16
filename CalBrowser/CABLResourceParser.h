//
//  CABLResourceParser.h
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/14/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CABLResourceParser : NSObject

-(void)parseWithData:(NSData *)data;

/*
 * An array of dictionaries parsed out of the data
 */
-(NSArray *)entries;

/*
 * Returns YES if there is more data available.  NO otherwise
 */
-(BOOL)hasMoreData;

/*
 * If the parsed data is incomplete and there is more data available,
 * this URI will contain a reference to the next set of data.  Or nil
 * if there is no more data available.
 */
-(NSString *)nextURI;
@end
