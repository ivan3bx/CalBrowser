//
//  CABLCalendar.m
//  CalBrowser
//
//  Created by Ivan Moscoso on 12/2/13.
//  Copyright (c) 2013 reboundable. All rights reserved.
//

#import "CABLResourceList.h"
#import "CABLResource.h"
#import "CABLConfig.h"


typedef void(^SuccessHandler)(NSArray *);
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
    if (self.shouldFetchFromCache) {
        //
        // Short-circuit any network loading
        //
        onSuccess([CABLResource findAll]);
    } else {
        //
        // Fetch from the network
        //
        [self fetchFromNetwork:onSuccess handleError:onError];
    }
}

/*
 * This method decides whether we should rely on cached resource information
 */
+ (BOOL)shouldFetchFromCache
{
    return [CABLResource numberOfEntries] > 0;
}

+(void)fetchFromNetwork:(SuccessHandler)onSuccess handleError:(ErrorHandler)onError
{
    CABLResourceList *list = [[CABLResourceList alloc] init];
    list.successHandler = onSuccess;
    list.errorHandler = onError;
    
    NSString *const BASE_URL    = @"https://apps-apis.google.com/a/feeds/calendar/resource/2.0";
    NSString *const APP_DOMAIN  = [CABLConfig sharedInstance].appsDomain;
    NSString *urlStringWithDomain = [NSString stringWithFormat:@"%@/%@/", BASE_URL, APP_DOMAIN];
    [list load:[CABLResourceList createRequest:urlStringWithDomain]];
}

+(NSURLRequest *)createRequest:(NSString *)urlString
{
    NXOAuth2Request *signedReq;
    signedReq = [[NXOAuth2Request alloc] initWithResource:[NSURL URLWithString:urlString]
                                                   method:@"GET"
                                               parameters:nil];
    
    //
    // Associate current user's account with this request
    //
    signedReq.account = [CABLConfig sharedInstance].currentAccount;
    
    //
    // Append content-type (since this API is XML)
    //
    NSMutableURLRequest *xmlRequest = [signedReq.signedURLRequest mutableCopy];
    [xmlRequest addValue:@"application/atom+xml" forHTTPHeaderField:@"Content-type"];
    return xmlRequest;
}

-(id)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        _data = [data mutableCopy];
        [self parseData];
    }
    return self;
}

-(void)parseData
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:_data];
    parser.delegate = self;
    [parser parse];
    _data = nil;
}

-(void)load:(NSURLRequest *)request
{
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(NSUInteger)count
{
    return _entries.count;
}

-(NSDictionary *)resourceForIndex:(NSUInteger)index
{
    return _entries[index];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate methods
#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    if (response.statusCode != 200) {
        NSDictionary *dict = @{@"statusCode" : [NSNumber numberWithInt:(int)response.statusCode],
                               @"message"    : @"Calendar resource list failed to load any data"};
        if (self.errorHandler) {
            self.errorHandler([NSError errorWithDomain:@"CalBrowser" code:1 userInfo:dict]);
        } else {
            NSLog(@"%@", dict);
        }
    }
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
    [self parseData];
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
    if (_nextURLString) {
        //
        // We have more data to fetch
        //
        NSURLRequest *nextReq = [CABLResourceList createRequest:_nextURLString];
        [self load:nextReq];
    } else {
        //
        // No additional data to fetch
        // - refresh the cache
        // - yield to the handler
        //
        [CABLResource reloadWithData:_entries];
        if (self.successHandler) {
            self.successHandler([CABLResource findAll]);
        }
    }
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









