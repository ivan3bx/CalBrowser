//
//  CABLResourceParser.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/14/13.
//  Copyright (c) 2013 Ivan Moscoso. All rights reserved.
//

#import "CABLResourceParser.h"
@interface CABLResourceParser() <NSXMLParserDelegate> {
    NSMutableArray *_entries;
    NSString *_nextURLString;
}
@end

@implementation CABLResourceParser

-(void)parseWithData:(NSData *)data
{
    _entries = [[NSMutableArray alloc] init];

    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];
}

-(BOOL)hasMoreData
{
    return _nextURLString != nil;
}

-(NSString *)nextURI
{
    return _nextURLString;
}

-(NSArray *)entries
{
    return [_entries copy];
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods
#pragma mark -

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    _nextURLString = nil;
}

/*
 * Start parsing a new entry, or find our next link..
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"link"] && [attributeDict[@"rel"] isEqualToString:@"next"]) {
        //
        // Eureka - Google Apps is telling us there's more data
        //
        _nextURLString = attributeDict[@"href"];
    } else if ([elementName isEqualToString:@"entry"]) {
        //
        // Append a new entry
        //
        NSMutableDictionary *newEntry = [[NSMutableDictionary alloc] init];
        [_entries addObject:newEntry];
    } else if ([elementName isEqualToString:@"apps:property"]) {
        //
        // Append some metadata to the current entry
        //
        NSMutableDictionary * dict = _entries.lastObject;
        dict[attributeDict[@"name"]] = attributeDict[@"value"];
    }
}

@end
