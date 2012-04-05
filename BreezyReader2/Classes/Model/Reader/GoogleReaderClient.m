//
//  GoogleReaderClient.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GoogleReaderClient.h"
#import "URLParameterSet.h"
#import "ASIFormDataRequest.h"
#import "GoogleAuthManager.h"
#import "NSString+SBJSON.h"
#import "NSString+Addtion.h"

@interface GoogleReaderClient ()

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL action;

@property (nonatomic, retain) ASIHTTPRequest* request;

@end

@implementation GoogleReaderClient

@synthesize delegate = _delegate, action = _action;
@synthesize request = _request;
@synthesize responseData = _responseData, responseString = _responseString, responseJSONValue = _responseJSONValue, error = _error;
@synthesize responseFeedSearchingJSONValue = _responseFeedSearchingJSONValue;

static NSString* _token = nil;

+(id)clientWithDelegate:(id)delegate action:(SEL)action{
    return [[[self alloc] initWithDelegate:delegate action:action] autorelease];
}

-(void)dealloc{
    [self.request clearDelegatesAndCancel];
    self.request = nil;
    [super dealloc];
}

-(id)initWithDelegate:(id)delegate action:(SEL)action{
    self = [super init];
    if (self){
        self.delegate = delegate;
        self.action = action;
    }
    
    return self;
}

-(void)clearAndCancel{
    [self.request clearDelegatesAndCancel];
    self.request = nil;
}

-(void)requestFeedWithIdentifier:(NSString*)identifer
                           count:(NSNumber*)count 
                       startFrom:(NSDate*)date 
                         exclude:(NSString*)excludeString 
                    continuation:(NSString*)continuationStr 
                    forceRefresh:(BOOL)refresh{
	URLParameterSet* parameterSet = [self compileParameterSetWithCount:count startFrom:date exclude:excludeString continuation:continuationStr];
    if (identifer.length == 0){
        NSLog(@"stream id should not be nil");
        return;
    }
    
//    NSMutableString* ID = [[identifer mutableCopy] autorelease];
//    [ID replaceURLCharacters];

	NSString* url = [API_STREAM_CONTENTS stringByAppendingString:[identifer stringByAddingPercentEscapesAndReplacingHTTPCharacter]];
    [self.request clearDelegatesAndCancel];
    self.request = [self requestWithURL:[self fullURLFromBaseString:url] parameters:parameterSet APIType:API_LIST];
    ASICachePolicy policy = ASIOnlyLoadIfNotCachedCachePolicy;
    if (refresh){
        policy = ASIDoNotReadFromCacheCachePolicy;
    }
    self.request.cachePolicy = policy;
    self.request.delegate = self;
    [self.request startAsynchronous];
}

-(void)getStreamDetails:(NSString*)streamID{
    URLParameterSet* parameters = [[[URLParameterSet alloc] init] autorelease];
    [parameters setParameterForKey:@"s" withValue:streamID];
    [parameters setParameterForKey:@"fetchTrends" withValue:@"false"];
    [parameters setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    [self.request clearDelegatesAndCancel];
    self.request = [self requestWithURL:[self fullURLFromBaseString:API_STREAM_DETAILS] parameters:parameters APIType:API_LIST];
    [[GoogleAuthManager shared] authRequest:self.request completionBlock:^(NSError* error){
        if (error == nil){
            [self.request startAsynchronous];
        }
    }];
}

-(void)queryContentsWithIDs:(NSArray*)IDArray{
    ASIFormDataRequest* request = [self requestWithURL:[self fullURLFromBaseString:API_STREAM_ITEMS_CONTENTS] parameters:nil APIType:API_EDIT];
    for (NSDictionary* ID in IDArray){
        [request addPostValue:[ID objectForKey:@"id"] forKey:CONTENTS_ARGS_ID];
        [request addPostValue:@"0" forKey:CONTENTS_ARGS_IT];
    }
    [request addPostValue:[[GoogleAuthManager shared] token] forKey:EDIT_ARGS_TOKEN];
    [self clearAndCancel];
    self.request = request;
    [[GoogleAuthManager shared] authRequest:self.request completionBlock:^(NSError* error){
        if (error == nil){
            [self.request startAsynchronous];
        }
    }];
}

-(void)searchArticlesWithKeywords:(NSString*)keywords{
    URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
    [paramSet setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    [paramSet setParameterForKey:SEARCH_ARGS_NUMBER withValue:[NSNumber numberWithInt:100]];
    [paramSet setParameterForKey:SEARCH_ARGS_QUERY withValue:keywords];
    [self clearAndCancel];
    self.request = [self requestWithURL:[self fullURLFromBaseString:API_SEARCH_ARTICLES] parameters:paramSet APIType:API_LIST];
    [[GoogleAuthManager shared] authRequest:self.request completionBlock:^(NSError* error){
        if (!error){
            [self.request startAsynchronous];
        }
    }];
}

-(void)searchFeedsWithKeywords:(NSString*)keywords{
    static NSString* feedSearchFormat = @"https://www.google.com/uds/GfindFeeds?rsz=8&callback=completion&context=0&hl=zh_CN&key=notsupplied&v=1.0&q=";
    
    [self clearAndCancel];
    self.request = nil;
    NSString* urlString = [feedSearchFormat stringByAppendingString:[keywords stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    DebugLog(@"searching url string is %@", urlString);
    NSURL* url = [NSURL URLWithString:urlString];
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
    request.cachePolicy = ASIOnlyLoadIfNotCachedCachePolicy;
    request.cacheStoragePolicy = ASICacheForSessionDurationCacheStoragePolicy;
    request.delegate = self;
    self.request = request;
    [self.request startAsynchronous];
}

#pragma mark - request delegate
-(void)requestStarted:(ASIHTTPRequest*)request{
}

-(void)requestFailed:(ASIHTTPRequest*)request{
    if (self.action){
        [self.delegate performSelectorOnMainThread:self.action withObject:self waitUntilDone:NO];
    }
}

-(void)requestFinished:(ASIHTTPRequest*)request{
    if (self.action){
        [self.delegate performSelectorOnMainThread:self.action withObject:self waitUntilDone:NO];
    }
}

#pragma mark - getter and setter
-(NSString*)responseString{
    return self.request.responseString;
}

-(NSData*)responseData{
    return self.request.responseData;
}

-(id)responseJSONValue{
    
    return [self.responseString JSONValue];
}

-(id)responseFeedSearchingJSONValue{
    NSString* resultString = self.responseString;
    
    NSInteger start = NSNotFound, end = NSNotFound;
    for (int i = 0; i<resultString.length; i++){
        if ([resultString characterAtIndex:i] == '{'){
            start = i;
            break;
        }
    }
    
    for (int i = resultString.length-1; i>=0; i--){
        if ([resultString characterAtIndex:i] == '}'){
            end = i;
            break;
        }
    }
    
    NSRange jsonRange = {start, end-start+1};
    NSString* json = [resultString substringWithRange:jsonRange];
    
    return [json JSONValue];
}

-(NSError*)error{
    return self.request.error;
}

#pragma mark - url parameters

-(URLParameterSet*)compileParameterSetWithCount:(NSNumber*)count 
									  startFrom:(NSDate*)date 
										exclude:(NSString*)excludeString 
                                   continuation:(NSString*)continuationStr {
	URLParameterSet* parameterSet = parameterSet = [[[URLParameterSet alloc] init] autorelease];;
	
    if (count)
        [parameterSet setParameterForKey:ATOM_ARGS_COUNT withValue:[count stringValue]];
    if (date)
        [parameterSet setParameterForKey:ATOM_ARGS_START_TIME withValue:[NSString stringWithFormat:@"%d", [date timeIntervalSince1970]]];
    if (excludeString)
        [parameterSet setParameterForKey:ATOM_ARGS_EXCLUDE_TARGET withValue:excludeString];
    if (continuationStr)
        [parameterSet setParameterForKey:ATOM_ARGS_CONTINUATION withValue:continuationStr];
    
    [parameterSet setParameterForKey:ATOM_ARGS_TIMESTAMP withValue:[NSDate date]];
	
	return parameterSet;
}

-(NSURL*)fullURLFromBaseString:(NSString*)string{
    //encode URL string
	NSString* googleScheme = GOOGLE_SCHEME_SSL;
//	NSString* encodedURLString = [googleScheme stringByAppendingString:[string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString* encodedURLString = [googleScheme stringByAppendingString:string];
	DebugLog(@"encoded URL String is %@", encodedURLString);
	//构造request
	return [NSURL URLWithString:encodedURLString];
}

-(id)requestWithURL:(NSURL*)baseURL
         parameters:(URLParameterSet*)parameters 
            APIType:(NSString*)type{
    ASIHTTPRequest* request = nil;
    if ([type isEqualToString:API_EDIT]){
        request = [ASIFormDataRequest requestWithURL:baseURL];
        request.requestMethod = @"POST";//POST method for list api
        [request appendPostData:[[parameters parameterString] dataUsingEncoding:NSUTF8StringEncoding]];
        URLParameterSet* additionalParameters = [[URLParameterSet alloc] init];
        
        [additionalParameters setParameterForKey:EDIT_ARGS_CLIENT withValue:CLIENT_IDENTIFIER];
        [additionalParameters setParameterForKey:EDIT_ARGS_SOURCE withValue:EDIT_ARGS_SOURCE_RECOMMENDATION];
        
        NSString* temp = [request.url absoluteString];
        temp = [temp stringByAppendingString:@"?"];
        temp = [temp stringByAppendingString:[additionalParameters parameterString]];
        [request setURL:[NSURL URLWithString:temp]];
        
        [additionalParameters release];
        
    }else{
        request = [ASIHTTPRequest requestWithURL:baseURL];
        request.requestMethod = @"GET";//GET method for others
        NSString* temp = [request.url absoluteString];
        if (parameters){
            temp = [temp stringByAppendingString:@"?"];
            temp = [temp stringByAppendingString:[parameters parameterString]];
        }
        [request setURL:[NSURL URLWithString:temp]];
    }
    
    request.delegate = self;
    request.cachePolicy = ASIOnlyLoadIfNotCachedCachePolicy;
    request.cacheStoragePolicy = ASICacheForSessionDurationCacheStoragePolicy;
    
    DebugLog(@"request string is %@", [request.url absoluteString]);
    
    return request;
}

-(BOOL)isLoading{
    return ![self.request isFinished];
}

@end
