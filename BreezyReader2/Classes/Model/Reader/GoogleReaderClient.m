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
#import "GRFeed.h"
#import "NSString+SBJSON.h"
#import "NSString+Addtion.h"

@interface FetchTokenArg: NSObject

@property (nonatomic, retain) id request;
@property (nonatomic, copy) id completionHandler; 

@end

@implementation FetchTokenArg

@synthesize request = _request, completionHandler = _completionHandler;

-(void)dealloc{
    self.request = nil;
    self.completionHandler = nil;
    [super dealloc];
}

@end

@interface GoogleReaderClient ()

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL action;

@property (nonatomic, retain) ASIHTTPRequest* request;
@property (nonatomic, retain) ASIHTTPRequest* tokenRequest;


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
@synthesize responseData, responseString, responseJSONValue, error = _error, isResponseOK, responseFeed;
@synthesize responseFeedSearchingJSONValue = _responseFeedSearchingJSONValue;
@synthesize tokenRequest = _tokenRequest;

static NSString* _token = nil;
static long long _tokenFetchTimeInterval = 0;
static BOOL _startFetchToken = NO;

+(id)clientWithDelegate:(id)delegate action:(SEL)action{
    return [[[self alloc] initWithDelegate:delegate action:action] autorelease];
}

#pragma mark - static containers
-(NSMutableArray*)addTokenQueue{
    static dispatch_once_t predTokenQueue;
    static NSMutableArray* _addTokenQueue = nil;
    
    dispatch_once(&predTokenQueue, ^{ 
        _addTokenQueue = [[NSMutableArray alloc] init]; 
    }); 
    
    return _addTokenQueue;
}

-(NSMutableDictionary*)itemPool{
    static dispatch_once_t predItems;
    static NSMutableDictionary* _items = nil;
    
    dispatch_once(&predItems, ^{ 
        _items = [[NSMutableDictionary alloc] init]; 
    }); 
    
    return _items;
}

-(NSMutableDictionary*)itemsForFeed{
    static dispatch_once_t predFeeds;
    static NSMutableDictionary* _feeds = nil;
    
    dispatch_once(&predFeeds, ^{ 
        _feeds = [[NSMutableDictionary alloc] init]; 
    }); 
    
    return _feeds;
}

-(NSMutableDictionary*)tags{
    static dispatch_once_t predTags;
    static NSMutableDictionary* _tags = nil;
    
    dispatch_once(&predTags, ^{ 
        _tags = [[NSMutableDictionary alloc] init]; 
    }); 
    
    return _tags;
}

-(NSMutableDictionary*)subscriptions{
    static dispatch_once_t predSubs;
    static NSMutableDictionary* _subs = nil;
    
    dispatch_once(&predSubs, ^{ 
        _subs = [[NSMutableDictionary alloc] init]; 
    }); 
    
    return _subs;
}

#pragma mark - token


+(NSString*)token{
    NSDate* now = [NSDate date];
    NSDate* tokenFetchedDate = [NSDate dateWithTimeIntervalSince1970:_tokenFetchTimeInterval];
    
    if ([now timeIntervalSinceDate:tokenFetchedDate] > 25*60){
        //token invalid time is 30 mins
        //refresh it after 25 mins
        [self setToken:nil];
        _tokenFetchTimeInterval = 0;
    }
        
    return _token;
}

+(void)setToken:(NSString*)token{
    [_token release];
    _token = [token copy];
}

-(void)refreshUnreadCount{
    
}

-(void)refreshTagAndSubscription{
    
}

#pragma mark - life cycle

-(void)dealloc{
    self.delegate = nil;
    [self.request clearDelegatesAndCancel];
    self.request = nil;
    [self.tokenRequest clearDelegatesAndCancel];
    self.tokenRequest = nil;
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

-(void)requestRecommendationList{
    NSString* url = [URI_PREFIX_API stringByAppendingString:API_LIST_RECOMMENDATION];
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	[paramSet setParameterForKey:ATOM_ARGS_COUNT withValue:@"99999"];
	[paramSet setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    [self.request clearDelegatesAndCancel];
    self.request = [self requestWithURL:[self fullURLFromBaseString:url] parameters:paramSet APIType:API_LIST];
    [[GoogleAuthManager shared] authRequest:self.request completionBlock:^(NSError* error){
        if (error == nil){
            [self.request startAsynchronous];
        }
    }];
}

-(void)requestSubscriptionList{
    
}

-(void)requestTagList{
    
}

-(void)requestUnreadCount{
    
}

#pragma mark - edit api
-(void)starArticle:(NSString*)itemID{
    [self editItem:itemID addTag:[[self class] starTag] removeTag:nil];
}

-(void)unstartArticle:(NSString*)itemID{
    [self editItem:itemID addTag:nil removeTag:[[self class] starTag]];
    
}

-(void)markArticleAsRead:(NSString*)itemID{
    [self editItem:itemID addTag:[[self class] readArticleTag] removeTag:nil];
}

-(void)markArticleAsUnread:(NSString*)itemID{
    [self editItem:itemID addTag:nil removeTag:[[self class] readArticleTag]];
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
    __block typeof(self) blockSelf = self;
    [self.request setCompletionBlock:^{
        DebugLog(@"mark all as read succeeded");
        NSArray* items = [[blockSelf itemsForFeed] objectForKey:streamID];
        [items makeObjectsPerformSelector:@selector(markAsRead)];
        [blockSelf performCallBack];
        [blockSelf performSelectorOnMainThread:@selector(refreshUnreadCount) withObject:self waitUntilDone:NO];
    }];
    [self.request setFailedBlock:^{
        DebugLog(@"mark all as read failed");
        [blockSelf performCallBack];
    }];
    
    [self addTokenToRequest:(ASIFormDataRequest*)_request completionBlock:^(NSError* error){
        if (error){
            [blockSelf performCallBack];
        }else{
            
            [[GoogleAuthManager shared] authRequest:_request completionBlock:^(NSError* error){
                if (error == nil){
                    [_request startAsynchronous];
                }
            }];
        }
    }];
}

-(void)recommendationStream:(NSString*)streamID{
    NSString* url = [URI_PREFIX_API stringByAppendingString:API_RECOMMENDATION_EDIT];
    
    URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
    [paramSet setParameterForKey:EDIT_ARGS_FEED withValue:streamID];
    [paramSet setParameterForKey:EDIT_ARGS_IMPRESSION withValue:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]*1000000]];
    self.request = [self requestWithURL:[self fullURLFromBaseString:url] parameters:paramSet APIType:API_EDIT];
    __block typeof(self) blockSelf = self;
    [self addTokenToRequest:(ASIFormDataRequest*)self.request completionBlock:^(NSError* error){
        if (error == nil){
            [[GoogleAuthManager shared] authRequest:blockSelf.request completionBlock:^(NSError* error){
                [blockSelf.request startAsynchronous];
            }];
        }
    }];
}

#pragma mark - request delegate
-(void)requestStarted:(ASIHTTPRequest*)request{
}

-(void)requestFailed:(ASIHTTPRequest*)request{
    [self performCallBack];
}

-(void)requestFinished:(ASIHTTPRequest*)request{
    [self performCallBack];
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

-(GRFeed*)responseFeed{
    GRFeed* feed = [GRFeed objWithJSON:self.responseJSONValue];
    if (self.request.didUseCachedResponse == NO){
        NSMutableArray* items = [[self itemsForFeed] objectForKey:feed.ID];
        if (items == nil){
            items = [NSMutableArray array];
            [[self itemsForFeed] setObject:items forKey:feed.ID];
        }
        [feed.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            GRItem* item = obj;
            [[self itemPool] setObject:item forKey:item.ID];
            [items addObject:item];
        }];
    }else{
        NSMutableArray* items = [NSMutableArray array];
        for (GRItem* item in feed.items){
            GRItem* origItem = [[self itemPool] objectForKey:item.ID];
            [items addObject:origItem];
        }
        feed.items = items;
    }
    
    return feed;
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
	
    ASIFormDataRequest* request = [self requestWithURL:[self fullURLFromBaseString:url] parameters:paramSet APIType:API_EDIT];
    
    __block typeof(self) blockSelf = self;
    [request setCompletionBlock:^{
        [blockSelf performCallBack];
        
        GRItem* item = [[blockSelf itemPool] objectForKey:itemID];
        [item removeCategory:tagToRemove];
        [item addCategory:tagToAdd];
    }];
    
    [request setFailedBlock:^{
        [blockSelf performCallBack];
    }];
    
    self.request = request;
 
    [self addTokenToRequest:request completionBlock:^(NSError* error){
        if (error){
            [blockSelf performCallBack];
        }else{

            [[GoogleAuthManager shared] authRequest:request completionBlock:^(NSError* error){
                if (error == nil){
                    DebugLog(@"address for request is %d", request);
                    [request startAsynchronous];
                }
            }];
        }
    }];
}

//add token if only needed
-(void)addTokenToRequest:(ASIFormDataRequest*)request completionBlock:(void(^)(NSError* error))block{
    NSString* token = [[self class] token];
    NSMutableArray* addTokenQueue = [self addTokenQueue];
    if (token == nil){
        @synchronized(addTokenQueue){
            FetchTokenArg* arg = [[[FetchTokenArg alloc] init] autorelease];
            arg.request = request;
            arg.completionHandler = block;
            
            [addTokenQueue addObject:arg];
        
            if (_startFetchToken == NO){
                //start fetch token
                _startFetchToken = YES;
                [self startFetchToken];
            }
        }
                
    }else{
        [request addPostValue:token forKey:EDIT_ARGS_TOKEN];
        if (block){
            block(nil);
        }
    }
}

-(void)startFetchToken{
    
    NSString* urlString = [URI_PREFIX_API stringByAppendingString:API_TOKEN];
    urlString = [GOOGLE_SCHEME_SSL stringByAppendingString:urlString];
    
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self.tokenRequest clearDelegatesAndCancel];
    self.tokenRequest = request;
    NSMutableArray* addTokenQueue = [self addTokenQueue];
    [request setCompletionBlock:^{
        if (request.error == nil){
            NSString* tempToken = request.responseString;
            
            DebugLog(@"token is %@", tempToken);
            
            if (tempToken != nil && [tempToken length] <= 57){
                [[GoogleReaderClient class] setToken:[tempToken substringFromIndex:2]];
                _tokenFetchTimeInterval = [[NSDate date] timeIntervalSince1970];
            }else {
                [[GoogleReaderClient class] setToken:nil];
                _tokenFetchTimeInterval = 0;
            }
            
            @synchronized(addTokenQueue){
                NSArray* args = [NSArray arrayWithArray:addTokenQueue];
                [addTokenQueue removeAllObjects];
                
                for (FetchTokenArg* arg in args){
                    [arg.request addPostValue:tempToken forKey:EDIT_ARGS_TOKEN];
                    if (arg.completionHandler){
                        void (^completionBlock)(NSError *) = arg.completionHandler;
                        completionBlock(request.error);
                    }
                }
            }
        }
        _startFetchToken = NO;
    }];
    
    [request setFailedBlock:^{
        @synchronized(addTokenQueue){
            NSArray* args = [NSArray arrayWithArray:addTokenQueue];
            [addTokenQueue removeAllObjects];
            
            for (FetchTokenArg* arg in args){
                if (arg.completionHandler){
                    void (^completionBlock)(NSError *) = arg.completionHandler;
                    completionBlock(request.error);
                }
            }
        }
        _startFetchToken = NO;
    }];
    
    [[GoogleAuthManager shared] authRequest:request completionBlock:^(NSError* error){
        if (error == nil){
            [request startAsynchronous];
        }
    }];

}

-(void)performCallBack{
    if (self.action){
        [self.delegate performSelectorOnMainThread:self.action withObject:self waitUntilDone:NO];
    }
}

#pragma mark - labels
+(NSString*)readArticleTag{
    return [ATOM_PREFIX_STATE_GOOGLE stringByAppendingString:ATOM_STATE_READ];
}

+(NSString*)starTag{
    return [ATOM_PREFIX_STATE_GOOGLE stringByAppendingString:ATOM_STATE_STARRED];
}

@end
