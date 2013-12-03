//
//  CABLCalendar.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/2/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import "CABLResourceList.h"
#import "CABLConfig.h"


typedef void(^SuccessHandler)(CABLResourceList *);
typedef void(^ErrorHandler)(NSError *);

@interface CABLResourceList() <NSXMLParserDelegate> {
    NSMutableArray *_entries;
    NSMutableData *_data;
    NSString *_nextURLString;
}

@property(nonatomic,readwrite,copy) SuccessHandler successHandler;
@property(nonatomic,readwrite,copy) ErrorHandler errorHandler;

@end

@implementation CABLResourceList

+(void)loadResourceList:(SuccessHandler)onSuccess error:(ErrorHandler)onError;
{
    CABLResourceList *list = [[CABLResourceList alloc] init];
    list.successHandler = onSuccess;
    list.errorHandler = onError;

    NSString *const BASE_URL    = @"https://apps-apis.google.com/a/feeds/calendar/resource/2.0";
    NSString *const APP_DOMAIN  = [CABLConfig sharedInstance].appsDomain;
    NSString *urlStringWithDomain = [NSString stringWithFormat:@"%@/%@/", BASE_URL, APP_DOMAIN];
    NSURLRequest *request = [CABLResourceList createRequest:urlStringWithDomain];
    [list load:request];
}

+(NSURLRequest *)createRequest:(NSString *)urlString
{
    NXOAuth2Request *signedReq;
    signedReq = [[NXOAuth2Request alloc] initWithResource:[NSURL URLWithString:urlString]
                                                   method:@"GET"
                                               parameters:nil];
    
    // Associate current user's account with this request
    signedReq.account = [CABLConfig sharedInstance].currentAccount;
    
    // Append content-type (since this API is XML)
    NSMutableURLRequest *xmlRequest = [signedReq.signedURLRequest mutableCopy];
    [xmlRequest addValue:@"application/atom+xml" forHTTPHeaderField:@"Content-type"];
    return xmlRequest;
}

-(void)load:(NSURLRequest *)request
{
    NSLog(@"Will start new request: %@", request.URL.absoluteString);
    [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate methods
#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Connection did receive response");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (_data == nil) {
        _data = [NSMutableData dataWithData:data];
    } else {
        [_data appendData:data];
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:_data];
    parser.delegate = self;
    [parser parse];
    _data = nil;
}


#pragma mark -
#pragma mark NSXMLParserDelegate methods
#pragma mark -

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    if (_entries == nil) {
        _entries = [[NSMutableArray alloc] init];
    }

    _nextURLString = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"I have %u entries, and next URL: %@", _entries.count, _nextURLString);
    if (_nextURLString) {
        NSURLRequest *nextReq = [CABLResourceList createRequest:_nextURLString];
        [self load:nextReq];
    }
}

/*
 * Start parsing a new entry, or find our next link..
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"link"] && [attributeDict[@"rel"] isEqualToString:@"next"]) {
        /*
         * Eureka - Google Apps is telling us there's more data
         */
        _nextURLString = attributeDict[@"href"];
    } else if ([elementName isEqualToString:@"entry"]) {
        /*
         * Append a new entry
         */
        NSMutableDictionary *newEntry = [[NSMutableDictionary alloc] init];
        [_entries addObject:newEntry];
    } else if ([elementName isEqualToString:@"apps:property"]) {
        /*
         * Append some metadata to the current entry
         */
        NSMutableDictionary * dict = _entries.lastObject;
        dict[attributeDict[@"name"]] = attributeDict[@"value"];
    }
}

/*
 * End parsing a new entry
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"entry"]) {
//        NSLog(@"Added new entry: %@", _entries.lastObject);
    }
}


@end









