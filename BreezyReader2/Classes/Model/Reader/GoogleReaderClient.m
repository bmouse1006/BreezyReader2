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
#import "ASINetworkQueue.h"
#import "GoogleAuthManager.h"
#import "GRFeed.h"
#import "NSString+SBJSON.h"
#import "NSString+Addtion.h"

#define TAGLIST_STORE_KEY @"TAGLIST_STORE_KEY"
#define SUBLIST_STORE_KEY @"SUBLIST_STORE_KEY"

#define UniversalTagList [[self class] tags]
#define UniversalSubList [[self class] subscriptions]
#define UniversalItemPool [[self class] itemPool]
#define UniversalUnreadCount [[self class] unreadCountMap]

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
@property (nonatomic, retain) ASINetworkQueue* requestQueue;

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
@synthesize requestQueue = _requestQueue;

static NSString* _token = nil;
static long long _tokenFetchTimeInterval = 0;
static BOOL _startFetchToken = NO;

static BOOL _needRefreshUnreadCount = NO;

static long long _lastUnreadCountRefreshTime;

+(id)clientWithDelegate:(id)delegate action:(SEL)action{
    return [[[self alloc] initWithDelegate:delegate action:action] autorelease];
}

#pragma mark - reader status
-(BOOL)needRefreshUnreadCount{
    return (_needRefreshUnreadCount)?YES:([[NSDate date] timeIntervalSince1970] - _lastUnreadCountRefreshTime > 25*60);
}

-(NSLock*)refreshingUnreadCountLock{
    static dispatch_once_t predUnreadLock;
    static NSLock* unreadCountLock = nil;
    
    dispatch_once(&predUnreadLock, ^{ 
        unreadCountLock = [[NSLock alloc] init]; 
    }); 
    
    return unreadCountLock;
}

-(NSLock*)refreshingReaderStructureLock{
    static dispatch_once_t predStructureLock;
    static NSLock* structureLock = nil;
    
    dispatch_once(&predStructureLock, ^{ 
        structureLock = [[NSLock alloc] init]; 
    }); 
    
    return structureLock;
}

#pragma mark - life cycle

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self clearAndCancel];
    [super dealloc];
}

-(id)initWithDelegate:(id)delegate action:(SEL)action{
    self = [super init];
    if (self){
        self.delegate = delegate;
        self.action = action;
        
        static dispatch_once_t classNotification;
        
        dispatch_once(&classNotification, ^{ 
            NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:[self class] selector:@selector(clearCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
            [nc addObserver:[self class] selector:@selector(saveReaderStructure) name:UIApplicationWillResignActiveNotification object:nil];
        }); 
        
    }
    
    return self;
}

-(void)clearAndCancel{
    [self clearAllRequests];
    self.delegate = nil;
    self.action = NULL;
}

-(void)clearAllRequests{
    [self.request clearDelegatesAndCancel];
    [self.requestQueue reset];
    [self.tokenRequest clearDelegatesAndCancel];
    self.requestQueue = nil;
    self.request = nil;
    self.tokenRequest = nil;
}

+(void)clearCache:(NSNotification*)notification{
    DebugLog(@"Clear cached data in Google Reader Client");
    @synchronized(UniversalItemPool){
        [UniversalItemPool removeAllObjects];
    }
    @synchronized([self itemsForFeed]){
        [[self itemsForFeed] removeAllObjects];
    }
}

#pragma mark - static containers

+(NSMutableArray*)addTokenQueue{
    static dispatch_once_t predTokenQueue;
    static NSMutableArray* _addTokenQueue = nil;
    
    dispatch_once(&predTokenQueue, ^{ 
        _addTokenQueue = [[NSMutableArray alloc] init]; 
    }); 
    
    return _addTokenQueue;
}

+(NSMutableDictionary*)itemPool{
    static dispatch_once_t predItems;
    static NSMutableDictionary* _items = nil;
    
    dispatch_once(&predItems, ^{ 
        _items = [[NSMutableDictionary alloc] init]; 
    }); 
    
    return _items;
}

+(NSMutableDictionary*)itemsForFeed{
    static dispatch_once_t predFeeds;
    static NSMutableDictionary* _feeds = nil;
    
    dispatch_once(&predFeeds, ^{ 
        _feeds = [[NSMutableDictionary alloc] init]; 
    }); 
    
    return _feeds;
}

+(NSMutableDictionary*)tags{
    static dispatch_once_t predTags;
    static NSMutableDictionary* _tags = nil;
    
    dispatch_once(&predTags, ^{ 
        _tags = [[NSMutableDictionary alloc] init]; 
    }); 
    
    return _tags;
}

+(NSMutableDictionary*)subscriptions{
    static dispatch_once_t predSubs;
    static NSMutableDictionary* _subs = nil;
    
    dispatch_once(&predSubs, ^{ 
        _subs = [[NSMutableDictionary alloc] init]; 
    }); 
    
    return _subs;
}

+(NSMutableDictionary*)unreadCountMap{
    static dispatch_once_t predUnread;
    static NSMutableDictionary* _unread = nil;
    
    dispatch_once(&predUnread, ^{ 
        _unread = [[NSMutableDictionary alloc] init]; 
    }); 
    
    return _unread;
}

+(NSLock*)locker{
    static dispatch_once_t predLock;
    static NSLock* _lock = nil;
    
    dispatch_once(&predLock, ^{ 
        _lock = [[NSLock alloc] init]; 
    }); 
    
    return _lock;    
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

#pragma mark - reader structure
+(BOOL)isReaderLoaded{
    [self restoreReaderStructure];
    return ([[self subscriptions] count] > 0 || [[self tags] count] > 0);
}

+(NSInteger)unreadCountWithID:(NSString*)key{
    NSDictionary* dict = UniversalUnreadCount;
    NSInteger unreadCount;
    @synchronized(dict){
        unreadCount = [[dict objectForKey:key] intValue];
    }
    
    return unreadCount;
}

+(GRTag*)tagWithID:(NSString*)key{
    NSDictionary* dict = UniversalTagList;
    id obj = nil;
    @synchronized(dict){
        obj = [dict objectForKey:key];
    }
    return obj;
}

+(NSArray*)tagListWithType:(BRTagType)type{
    NSMutableArray* tags = [NSMutableArray array];
    NSString* typeString = (type == BRTagTypeLabel)?@"label":@"state";
    
    [UniversalTagList enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
        GRTag* tag = obj;
        if ([tag.typeString isEqualToString:typeString]){
            [tags addObject:tag];
        }
    }];
    
    return tags;
}

+(GRSubscription*)subscriptionWithID:(NSString*)key{
    NSDictionary* dict = UniversalSubList;
    id obj = nil;
    @synchronized(dict){
        obj = [dict objectForKey:key];
    }
    return obj;
}

+(NSArray*)subscriptionsWithTagID:(NSString*)tagID{
    NSMutableArray* subs = [NSMutableArray array];

    @synchronized(UniversalSubList){
        [UniversalSubList enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop){
            GRSubscription* sub = obj;
            if ([sub.categories containsObject:tagID]||((tagID.length == 0) && [sub.categories count] == 0)){
                [subs addObject:sub];
            }
        }];
    }
    
    return subs;
}

-(void)refreshUnreadCount{
    NSString* url = [URI_PREFIX_API stringByAppendingString:API_LIST_UNREAD_COUNT];
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
    [paramSet setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    [self.request clearDelegatesAndCancel];
    self.request = [self requestWithURL:[self fullURLFromBaseString:url] parameters:paramSet APIType:API_LIST];
    __block typeof(self) blockSelf = self;
    
    self.request.didFinishSelector = @selector(unreadCountRequestFinished:);
    self.request.cachePolicy = ASIDoNotReadFromCacheCachePolicy;
    
    [[GoogleAuthManager shared] authRequest:self.request completionBlock:^(NSError* error){
        if (error == nil){
            [self postNotification:NOTIFICATION_BEGIN_UPDATEUNREADCOUNT object:nil];
            [blockSelf.request startAsynchronous];
        }
    }];
}

-(void)unreadCountRequestFinished:(ASIHTTPRequest*)request{
    _needRefreshUnreadCount = NO;
    _lastUnreadCountRefreshTime = [[NSDate date] timeIntervalSince1970];
    DebugLog(@"received response is %@", request.responseString);
    NSArray* tempUnreadArray = [[request.responseString JSONValue] objectForKey:@"unreadcounts"];
    NSMutableDictionary* unreadCount = UniversalUnreadCount;
    
    [unreadCount removeAllObjects];
    [tempUnreadArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop){
        NSString* ID = [obj objectForKey:@"id"];
        NSTimeInterval timeStamp = [[unreadCount objectForKey:@"newestItemTimestampUsec"] doubleValue];
        [unreadCount setObject:[obj objectForKey:@"count"] forKey:ID];
        if ([ID hasPrefix:@"feed"]){
            GRSubscription* sub = [[self class] subscriptionWithID:ID];
            sub.newestItemTimestampUsec = timeStamp;
        }else{
            GRTag* tag = [[self class] tagWithID:ID];
            tag.newestItemTimestampUsec = timeStamp;
        }
    }];
    
    DebugLog(@"unread count refresh finished");
    [self postNotification:NOTIFICAITON_END_UPDATEUNREADCOUNT object:nil];
    [self performCallBack];
}

-(void)refreshReaderStructure{
    
    [self.requestQueue reset];
    ASINetworkQueue* queue = [ASINetworkQueue queue];
    queue.delegate = self;
    queue.shouldCancelAllRequestsOnFailure = YES;
    queue.maxConcurrentOperationCount = 1;
    queue.queueDidFinishSelector = @selector(tagAndSubRequestFinished:);
    ASIHTTPRequest* subReq = [self requestForSubscriptionList];
    ASIHTTPRequest* tagReq = [self requestForTagList];
    [queue addOperation:tagReq];
    [queue addOperation:subReq];
    
    self.requestQueue = queue;
    
    [self postNotification:NOTIFICATION_BEGIN_UPDATEREADERSTRUCTURE object:nil];
    __block typeof(self) blockSelf = self;
    
    [[GoogleAuthManager shared] authRequest:tagReq completionBlock:^(NSError* error){
        if (error == nil){
            [[GoogleAuthManager shared] authRequest:subReq completionBlock:^(NSError* error){
                if (error == nil){
                    [blockSelf.requestQueue go];
                }
            }];
        }else{ 
            NSLog(@"auth log: %@", [error localizedDescription]);
        }
    }];
}

-(void)refreshSubscriptionList{
    [self.request clearDelegatesAndCancel];
    self.request = [self requestForSubscriptionList];
    __block typeof(self) blockSelf = self;
    [[GoogleAuthManager shared] authRequest:self.request completionBlock:^(NSError* error){
        if (error == nil){
            [blockSelf.request startAsynchronous];
        }
    }];
}

-(ASIHTTPRequest*)requestForTagList{
    
    NSString* taglistString = [URI_PREFIX_API stringByAppendingString:API_LIST_TAG];
    URLParameterSet* tagParam = [[[URLParameterSet alloc] init] autorelease];
    [tagParam setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    ASIHTTPRequest* tagRequest = [self requestWithURL:[self fullURLFromBaseString:taglistString] parameters:tagParam APIType:API_LIST]; 
    tagRequest.didStartSelector = @selector(tagRequestStarted:);
    tagRequest.didFinishSelector = @selector(tagRequestFinished:);
    
    return tagRequest;
}

-(ASIHTTPRequest*)requestForSubscriptionList{
    NSString* sublistString = [URI_PREFIX_API stringByAppendingString:API_LIST_SUBSCRIPTION];
    URLParameterSet* subParam = [[[URLParameterSet alloc] init] autorelease];
    [subParam setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    
    ASIHTTPRequest* subRequest = [self requestWithURL:[self fullURLFromBaseString:sublistString] parameters:subParam APIType:API_LIST];
    subRequest.didFinishSelector = @selector(subRequestFinished:);
    subRequest.didStartSelector = @selector(subRequestStarted:);
    
    return subRequest;
}

-(void)subRequestStarted:(ASIHTTPRequest*)request{
    DebugLog(@"subscriptions list request started");
    [self postNotification:NOTIFICATION_BEGIN_UPDATESUBSCRIPTIONLIST object:nil];
}

-(void)subRequestFinished:(ASIHTTPRequest*)request{
    NSArray* subs = [[request.responseString JSONValue] objectForKey:@"subscriptions"];
    NSMutableDictionary* subMap = UniversalSubList;
    @synchronized(subMap){
        [subMap removeAllObjects];
        [subs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            GRSubscription* sub = [GRSubscription subscriptionWithJSONObject:obj];
            [subMap setObject:sub forKey:sub.ID];
        }];
    }
    DebugLog(@"subscriptions list request finished");
    [self postNotification:NOTIFICAITON_END_UPDATESUBSCRIPTIONLIST object:nil];
}

-(void)tagRequestStarted:(ASIHTTPRequest*)request{
    DebugLog(@"tags list request started");
    [self postNotification:NOTIFICATION_BEGIN_UPDATETAGLIST object:nil];
}

-(void)tagRequestFinished:(ASIHTTPRequest*)request{
    NSArray* tags = [[request.responseString JSONValue] objectForKey:@"tags"];
    NSMutableDictionary* tagMap = UniversalTagList;
    @synchronized(tagMap){
        [tagMap removeAllObjects];
        [tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            GRTag* tag = [GRTag tagWithJSONObject:obj];
            [tagMap setObject:tag forKey:tag.ID];
        }];
    }
    DebugLog(@"tags list request finished");
    [self postNotification:NOTIFICAITON_END_UPDATETAGLIST object:nil];
}

-(void)tagAndSubRequestFinished:(ASINetworkQueue*)queue{
    //send out notification
    [self postNotification:NOTIFICAITON_END_UPDATEREADERSTRUCTURE object:nil];
    [self refreshUnreadCount];
}
                            
+(void)saveReaderStructure{
    [[self locker] lock];
    
    [NSKeyedArchiver archiveRootObject:UniversalTagList toFile:[self filePathWithName:@"taglist"]];
    [NSKeyedArchiver archiveRootObject:UniversalSubList toFile:[self filePathWithName:@"sublist"]];
    [NSKeyedArchiver archiveRootObject:UniversalUnreadCount toFile:[self filePathWithName:@"unreadcount"]];
    
    [[self locker] unlock];
}

+(void)restoreReaderStructure{
    [[self locker] lock];
    [UniversalSubList setDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathWithName:@"sublist"]]];
    [UniversalTagList setDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathWithName:@"taglist"]]];
    [UniversalUnreadCount setDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathWithName:@"unreadcount"]]];
     
    [[self locker] unlock];
}
     
+(NSString*)filePathWithName:(NSString*)name{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if (!documentsDirectory) {
        DebugLog(@"Documents directory not found!");
        return @"";
    }

    return [documentsDirectory stringByAppendingPathComponent:name];
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
        __block typeof(self) blockSelf = self;
        [[GoogleAuthManager shared] authRequest:self.request completionBlock:^(NSError* error){
            if (error == nil){
                [blockSelf.request startAsynchronous];
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
    self.request.cachePolicy = ASIOnlyLoadIfNotCachedCachePolicy;
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
    [self clearAllRequests];
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
    [self clearAllRequests];
    self.request = [self requestWithURL:[self fullURLFromBaseString:API_SEARCH_ARTICLES] parameters:paramSet APIType:API_LIST];
    [[GoogleAuthManager shared] authRequest:self.request completionBlock:^(NSError* error){
        if (error == nil){
            [self.request startAsynchronous];
        }
    }];
}

-(void)searchFeedsWithKeywords:(NSString*)keywords{
    static NSString* feedSearchFormat = @"https://www.google.com/uds/GfindFeeds?rsz=8&callback=completion&context=0&hl=zh_CN&key=notsupplied&v=1.0&q=";
    
    [self clearAllRequests];
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
    [self listRequestWithURL:[self fullURLFromBaseString:url] parameters:paramSet];
}

-(void)requestRelatedSubscriptions:(NSString*)streamID{
    if (streamID.length == 0){
        return;
    }
    NSString* url = [URI_PREFIX_API stringByAppendingString:API_LIST_RELATED];
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	[paramSet setParameterForKey:EDIT_ARGS_FEED withValue:streamID];
	[paramSet setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    [self.request clearDelegatesAndCancel];
    self.request = [self requestWithURL:[self fullURLFromBaseString:url] parameters:paramSet APIType:API_LIST];
    self.request.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
    __block typeof(self) blockSelf = self;
    [[GoogleAuthManager shared] authRequest:self.request completionBlock:^(NSError* error){
        if (error == nil){
            [blockSelf.request startAsynchronous];
        }
    }];
}

-(void)listRequestWithURL:(NSURL*)url parameters:(URLParameterSet*)parameters{
    [self.request clearDelegatesAndCancel];
    self.request = [self requestWithURL:url parameters:parameters APIType:API_LIST];
    __block typeof(self) blockSelf = self;
    [[GoogleAuthManager shared] authRequest:self.request completionBlock:^(NSError* error){
        if (error == nil){
            [blockSelf.request startAsynchronous];
        }
    }];
}

#pragma mark - edit api
-(void)starArticle:(NSString*)itemID{
    [self editItem:itemID addTag:[[self class] starTag] removeTag:nil];
}

-(void)unstartArticle:(NSString*)itemID{
    [self editItem:itemID addTag:nil removeTag:[[self class] starTag]];
    
}

-(void)markArticleAsRead:(NSString*)itemID{
    _needRefreshUnreadCount = YES;
    [self editItem:itemID addTag:[[self class] readArticleTag] removeTag:nil];
}

-(void)markArticleAsUnread:(NSString*)itemID{
    _needRefreshUnreadCount = YES;
    [self editItem:itemID addTag:nil removeTag:[[self class] readArticleTag]];
}

-(void)keepArticleUnread:(NSString*)itemID{
    NSString* keptUnread = [ATOM_PREFIX_STATE_GOOGLE stringByAppendingString:ATOM_STATE_UNREAD];
    [self editItem:itemID addTag:keptUnread removeTag:nil];
}

-(void)markAllAsRead:(NSString*)streamID{
    _needRefreshUnreadCount = YES;
    NSString* url = [URI_PREFIX_API stringByAppendingString:API_EDIT_MARK_ALL_AS_READ];
	//Prepare parameters
	URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
	
	[paramSet setParameterForKey:EDIT_ARGS_FEED withValue:streamID];//add feed URI
    
    [self clearAllRequests];
    self.request = [self requestWithURL:[self fullURLFromBaseString:url] parameters:paramSet APIType:API_EDIT];
    __block typeof(self) blockSelf = self;
    [self.request setCompletionBlock:^{
        DebugLog(@"mark all as read succeeded");
        NSArray* items = [[[blockSelf class] itemsForFeed] objectForKey:streamID];
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

-(void)viewRecommendationStream:(NSString*)streamID{
    [self editRecommendationStream:streamID action:@"view"];
}

-(void)dismissRecommendationStream:(NSString*)streamID{
    [self editRecommendationStream:streamID action:@"dismiss"];
}

-(void)editRecommendationStream:(NSString*)streamID action:(NSString*)action{
    NSString* url = [URI_PREFIX_API stringByAppendingString:API_RECOMMENDATION_EDIT];
    
    URLParameterSet* paramSet = [[[URLParameterSet alloc] init] autorelease];
    [paramSet setParameterForKey:EDIT_ARGS_FEED withValue:streamID];
    [paramSet setParameterForKey:EDIT_ARGS_RECOMMENDATION_ACTION withValue:action];
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
        NSMutableDictionary* itemsForFeed = [[self class] itemsForFeed];
        NSMutableArray* items = nil;
        @synchronized(itemsForFeed){
            items = [itemsForFeed objectForKey:feed.ID];
            if (items == nil){
                items = [NSMutableArray array];
                [[[self class] itemsForFeed] setObject:items forKey:feed.ID];
            }
            [items addObjectsFromArray:feed.items];
        }
        
        [feed.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            GRItem* item = obj;
            @synchronized(UniversalItemPool){
                [UniversalItemPool setObject:item forKey:item.ID];
            }
            [items addObject:item];
        }];
    }else{
        NSMutableArray* items = [NSMutableArray array];
       @synchronized(UniversalItemPool){
           for (GRItem* item in feed.items){
                GRItem* origItem = [UniversalItemPool objectForKey:item.ID];
                if (origItem == nil){
                    [UniversalItemPool setObject:item forKey:item.ID];
                    origItem = item;
                }
                [items addObject:origItem];
            }
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
        
        GRItem* item = [[[blockSelf class] itemPool] objectForKey:itemID];
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
    NSMutableArray* addTokenQueue = [[self class] addTokenQueue];
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
    NSMutableArray* addTokenQueue = [[self class] addTokenQueue];
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

#pragma mark - send notification
-(void)postNotification:(NSString*)name object:(id)object{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:object];
    });
}
     

@end
