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
@property (nonatomic, retain) NSOperationQueue* editOperationQueue;

@property (nonatomic, retain) ASIHTTPRequest* request;

//add/remove tag to one subscription
-(void)editSubscription:(NSString*)subscription 
					tagToAdd:(NSString*)tagToAdd 
				 tagToRemove:(NSString*)tagToRemove;

-(void)editItem:(NSString*)itemID 
			  addTag:(NSString*)tagToAdd 
		   removeTag:(NSString*)tagToRemove;

@end

@implementation GoogleReaderClient

@synthesize delegate = _delegate, action = _action;
@synthesize request = _request;
@synthesize responseData, responseString, responseJSONValue, error = _error, isResponseOK;
@synthesize responseFeedSearchingJSONValue = _responseFeedSearchingJSONValue;
@synthesize editOperationQueue = _editOperationQueue;

static NSString* _token = nil;
static NSTimer* _timer = nil;

+(id)clientWithDelegate:(id)delegate action:(SEL)action{
    return [[[self alloc] initWithDelegate:delegate action:action] autorelease];
}

#pragma mark - token

+(void)refreshToken{
    NSString* urlString = [URI_PREFIX_API stringByAppendingString:API_TOKEN];
    urlString = [GOOGLE_SCHEME_SSL stringByAppendingString:urlString];
    
    ASIHTTPRequest* request = [[ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]] autorelease];
    [request setCompletionBlock:^{
        NSString* tempToken = [[NSString alloc] initWithData:request.responseData encoding:NSUTF8StringEncoding];
        
        DebugLog(@"token is %@", tempToken);
        
        if (tempToken != nil && [tempToken length] <= 57){
            _token = [[tempToken substringFromIndex:2] copy];
        }else {
            _token = nil;
        }
        [tempToken release];
    }];
    [request setFailedBlock:^{
        //handle error  
    }];
    [[GoogleAuthManager shared] authRequest:request completionBlock:^(NSError* error){
        [request startAsynchronous];
    }];
}

+(NSString*)token{
    return _token;
}

+(void)startTimerToRefreshToken{
    _timer = [NSTimer timerWithTimeInterval:60*20 target:[self class] selector:@selector(refreshToken) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

+(void)invalideTimer{
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - life cycle

-(void)dealloc{
    [self.request clearDelegatesAndCancel];
    self.request = nil;
    [self.editOperationQueue.operations makeObjectsPerformSelector:@selector(clearDelegatesAndCancel)];
    [self.editOperationQueue cancelAllOperations];
    self.editOperationQueue = nil;
    [super dealloc];
}

-(id)initWithDelegate:(id)delegate action:(SEL)action{
    self = [super init];
    if (self){
        self.delegate = delegate;
        self.action = action;
        self.editOperationQueue = [[[NSOperationQueue alloc] init] autorelease];
    }
    
    return self;
}

-(void)clearAndCancel{
    [self.request clearDelegatesAndCancel];
    self.request = nil;
}

#pragma mark - list api

-(void)requestFeedWithIdentifier:(NSString*)identifer
                           count:(NSNumber*)count 
                       startFrom:(NSDate*)date 
                         exclude:(NSString*)excludeString 
                    continuation:(NSString*)continuationStr 
                    forceRefresh:(BOOL)refresh
                        needAuth:(BOOL)needAuth{
	URLParameterSet* parameterSet = [self compileParameterSetWithCount:count startFrom:date exclude:excludeString continuation:continuationStr];
    if (identifer.length == 0){
        NSLog(@"stream id should not be nil");
        return;
    }
    
	NSString* url = [API_STREAM_CONTENTS stringByAppendingString:[identifer stringByAddingPercentEscapesAndReplacingHTTPCharacter]];
    [self.request clearDelegatesAndCancel];
    self.request = [self requestWithURL:[self fullURLFromBaseString:url] parameters:parameterSet APIType:API_LIST];
    ASICachePolicy policy = ASIOnlyLoadIfNotCachedCachePolicy;
    if (refresh){
        policy = ASIDoNotReadFromCacheCachePolicy;
    }
    self.request.cachePolicy = policy;
    self.request.delegate = self;
    if (needAuth){
        [[GoogleAuthManager shared] authRequest:self.request completionBlock:^(NSError* error){
            if (error == nil){
                [self.request startAsynchronous];
            }
        }];
    }else{
        [self.request startAsynchronous];
    }
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
        if (error == nil){
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

-(void)getSubscriptionList{
    
}

-(void)getTagList{
    
}

-(void)getUnreadCount{
    
}

#pragma mark - edit api
-(void)starArticle:(NSString*)itemID{
    NSString* starTag = [ATOM_PREFIX_STATE_GOOGLE stringByAppendingString:ATOM_STATE_STARRED];
    [self editItem:itemID addTag:starTag removeTag:nil];
}

-(void)unstartArticle:(NSString*)itemID{
    NSString* starTag = [ATOM_PREFIX_STATE_GOOGLE stringByAppendingString:ATOM_STATE_STARRED];
    [self editItem:itemID addTag:nil removeTag:starTag];
    
}

-(void)markArticleAsRead:(NSString*)itemID{
    NSString* readTag = [ATOM_PREFIX_STATE_GOOGLE stringByAppendingString:ATOM_STATE_READ];
    [self editItem:itemID addTag:readTag removeTag:nil];
}

-(void)keepArticleUnread:(NSString*)itemID{
    NSString* keptUnread = [ATOM_PREFIX_STATE_GOOGLE stringByAppendingString:ATOM_STATE_UNREAD];
    [self editItem:itemID addTag:keptUnread removeTag:nil];
}

-(void)markAllAsRead:(NSString*)streamID{
    NSString* url = [URI_PREFIX_API stringByAppendingString:API_EDIT_MARK_ALL_AS_READ];
	//Prepare parameters
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	
	[paramSet setParameterForKey:EDIT_ARGS_FEED withValue:streamID];//add feed URI
    
    [self clearAndCancel];
    self.request = [self requestWithURL:[self fullURLFromBaseString:url] parameters:paramSet APIType:API_EDIT];
    
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
    DebugLog(@"%@", resultString);
    
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

-(BOOL)isResponseOK{
    DebugLog(@"response header is %@", self.request.responseHeaders);
    return [self.request.responseString compare:@"ok" options:NSCaseInsensitiveSearch] == NSOrderedSame;
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
        [parameters setParameterForKey:EDIT_ARGS_TOKEN withValue:_token];
        for (NSString* key in parameters.parameters.allKeys){
            [(ASIFormDataRequest*)request addPostValue:[parameters.parameters objectForKey:key] forKey:key];
        }
        URLParameterSet* additionalParameters = [[URLParameterSet alloc] init];
        
        [additionalParameters setParameterForKey:EDIT_ARGS_CLIENT withValue:CLIENT_IDENTIFIER];
        [additionalParameters setParameterForKey:EDIT_ARGS_SOURCE withValue:EDIT_ARGS_SOURCE_RECOMMENDATION];
        
        NSString* temp = [request.url absoluteString];
        temp = [temp stringByAppendingString:@"?"];
        temp = [temp stringByAppendingString:[additionalParameters parameterString]];
        [request setURL:[NSURL URLWithString:temp]];
        
        [additionalParameters release];
        request.cachePolicy = ASIDoNotReadFromCacheCachePolicy;
    }else{
        request = [ASIHTTPRequest requestWithURL:baseURL];
        request.requestMethod = @"GET";//GET method for others
        NSString* temp = [request.url absoluteString];
        if (parameters){
            temp = [temp stringByAppendingString:@"?"];
            temp = [temp stringByAppendingString:[parameters parameterString]];
        }
        [request setURL:[NSURL URLWithString:temp]];
        request.cachePolicy = ASIOnlyLoadIfNotCachedCachePolicy;
    }
    
    request.delegate = self;
    request.cacheStoragePolicy = ASICacheForSessionDurationCacheStoragePolicy;
    
    DebugLog(@"request string is %@", [request.url absoluteString]);
    
    return request;
}

-(BOOL)isLoading{
    return ![self.request isFinished];
}

#pragma mark - private methods
//add/remove tag to one subscription
-(void)editSubscription:(NSString*)subscription 
					tagToAdd:(NSString*)tagToAdd 
				 tagToRemove:(NSString*)tagToRemove{
    
}
     
-(void)editItem:(NSString*)itemID 
            addTag:(NSString*)tagToAdd 
         removeTag:(NSString*)tagToRemove{
    NSString* url = [URI_PREFIX_API stringByAppendingString:API_EDIT_TAG2];
	//Prepare parameters
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	[paramSet setParameterForKey:EDIT_ARGS_ITEM withValue:itemID];//add feed URI
	if (tagToAdd != nil)
		[paramSet setParameterForKey:EDIT_ARGS_ADD withValue:tagToAdd];//tag name to add
	if (tagToRemove != nil)
		[paramSet setParameterForKey:EDIT_ARGS_REMOVE withValue:tagToRemove];//tag name to remove
	[paramSet setParameterForKey:EDIT_ARGS_ACTION withValue:@"edit"];//add API action. Here is 'edit'
	
    ASIHTTPRequest* request = [self requestWithURL:[self fullURLFromBaseString:url] parameters:paramSet APIType:API_EDIT];
    request.delegate = self;
    self.request = request;
    [[GoogleAuthManager shared] authRequest:self.request completionBlock:^(NSError* error){
        if (error == nil){
            [self.request startAsynchronous];
        }
    }];
}

@end
