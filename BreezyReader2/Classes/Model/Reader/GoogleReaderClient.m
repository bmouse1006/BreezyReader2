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
#import "BRReadingStatistics.h"
#import "NSString+Addition.h"

#define TAGLIST_STORE_KEY @"TAGLIST_STORE_KEY"
#define SUBLIST_STORE_KEY @"SUBLIST_STORE_KEY"

#define UniversalTagList [GoogleReaderClient tags]
#define UniversalSubList [GoogleReaderClient subscriptions]
#define UniversalItemPool [GoogleReaderClient itemPool]
#define UniversalUnreadCount [GoogleReaderClient unreadCountMap]

@interface FetchTokenArg: NSObject

@property (nonatomic, unsafe_unretained) id request;
@property (nonatomic, copy) id completionHandler; 

@end

@implementation FetchTokenArg

@synthesize request = _request, completionHandler = _completionHandler;

-(void)dealloc{
    self.request = nil;
}

@end

@interface GoogleReaderClient ()

@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic, assign) SEL action;
@property (nonatomic, copy) id delegateCompletionHandler;

@property (nonatomic, strong) ASIHTTPRequest* request;
@property (nonatomic, strong) ASIHTTPRequest* tokenRequest;
@property (nonatomic, strong) ASINetworkQueue* requestQueue;

@property (nonatomic, copy) id requestInternalCompletionBlock;

@property (nonatomic, strong) NSError* reportError;

//add/remove tag to one subscription
-(void)editSubscription:(NSString*)subscription 
					tagToAdd:(NSString*)tagToAdd 
				 tagToRemove:(NSString*)tagToRemove;

-(void)editItem:(NSString*)itemID 
			  addTag:(NSString*)tagToAdd 
		   removeTag:(NSString*)tagToRemove;

@end
 
@implementation GoogleReaderClient

@synthesize reportError = _reportError;
@synthesize delegateCompletionHandler = _delegateCompletionHandler;
@synthesize requestInternalCompletionBlock = _requestInternalCompletionBlock;
@synthesize delegate = _delegate, action = _action;
@synthesize request = _request;
@synthesize responseData, responseString, responseJSONValue, error = _error, isResponseOK, responseFeed, didUseCachedData;
@synthesize responseFeedSearchingJSONValue = _responseFeedSearchingJSONValue;
@synthesize tokenRequest = _tokenRequest;
@synthesize requestQueue = _requestQueue;

static NSString* _token = nil;
static long long _tokenFetchTimeInterval = 0;

static BOOL _needRefreshUnreadCount = NO;
static BOOL _needRefreshReaderStructure = NO;
static BOOL _needRefreshRecommendation = NO;

static long long _lastUnreadCountRefreshTime;

static NSString* _userID = nil;

+(id)clientWithDelegate:(id)delegate action:(SEL)action{
    return [[self alloc] initWithDelegate:delegate action:action];
}

-(void)setCompletionHandler:(GoogleReaderCompletionHandler)block{
    self.delegateCompletionHandler = block;
}

#pragma mark - reader status
+(BOOL)needRefreshUnreadCount{
    return (_needRefreshUnreadCount)?YES:([[NSDate date] timeIntervalSince1970] - _lastUnreadCountRefreshTime > 25*60) && [self isReaderLoaded];;
}

+(BOOL)needRefreshReaderStructure{
    return _needRefreshReaderStructure && [self isReaderLoaded];
}

+(BOOL)needRefreshRecommendation{
    return _needRefreshRecommendation && [self isReaderLoaded];;
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
    self.requestInternalCompletionBlock = nil;
    self.delegateCompletionHandler = nil;
    self.reportError = nil;
}

-(void)clearAllRequests{
    [self.request clearDelegatesAndCancel];
    for (ASIHTTPRequest* request in self.requestQueue.operations){
        [request clearDelegatesAndCancel];
    }
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

+(NSLock*)tokenFetchingLock{
    static dispatch_once_t predTokenLock;
    static NSLock* _tokenFetchingLock = nil;
    
    dispatch_once(&predTokenLock, ^{ 
        _tokenFetchingLock = [[NSLock alloc] init]; 
    }); 
    
    return _tokenFetchingLock;
}

+(NSOperationQueue*)highPriorityQueue{
    static dispatch_once_t hightQueueToken;
    static NSOperationQueue* _hightPriorityQueue = nil;
    
    dispatch_once(&hightQueueToken, ^{ 
        _hightPriorityQueue = [[NSOperationQueue alloc] init]; 
        [_hightPriorityQueue setMaxConcurrentOperationCount:10];
    }); 
    
    return _hightPriorityQueue;    
}

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
    _token = [token copy];
}

#pragma mark - reader structure
+(BOOL)isReaderLoaded{
    BOOL result = ([UniversalSubList count] > 0 || [UniversalTagList count] > 0);
    if (result == NO){
        [self restoreReaderStructure];
        result = ([UniversalSubList count] > 0 || [UniversalTagList count] > 0);
    }
    return result;
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

+(BOOL)containsSubscription:(NSString*)subID{
    return [UniversalSubList objectForKey:subID] != nil;
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
	URLParameterSet* paramSet = [[URLParameterSet alloc] init];
    [paramSet setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    [self.request clearDelegatesAndCancel];
    self.request = [self requestWithURL:[self fullURLFromBaseString:url] parameters:paramSet APIType:API_LIST];
    __block typeof(self) blockSelf = self;
    
    self.request.didFinishSelector = @selector(unreadCountRequestFinished:);
    self.request.cachePolicy = ASIDoNotReadFromCacheCachePolicy;
    
    [[GoogleAuthManager shared] authRequest:self.request completionBlock:^(NSError* error){
        if (error == nil){
            [self postNotification:NOTIFICATION_BEGIN_UPDATEUNREADCOUNT object:nil];
            @try {
                [blockSelf.request startAsynchronous];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", [exception reason]);
            }
        }
    }];
}

-(void)unreadCountRequestFinished:(ASIHTTPRequest*)request{
    _needRefreshUnreadCount = NO;
    _lastUnreadCountRefreshTime = [[NSDate date] timeIntervalSince1970];
    DebugLog(@"received response is %@", request.responseString);
    NSArray* tempUnreadArray = [[NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingAllowFragments error:nil] objectForKey:@"unreadcounts"];
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
    [[self class] saveReaderStructure];
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
    queue.requestDidFailSelector = @selector(tagAndSubRequestFailed:);
    ASIHTTPRequest* subReq = [self requestForSubscriptionList];
    ASIHTTPRequest* tagReq = [self requestForTagList];
    subReq.didFailSelector = NULL;
    tagReq.didFailSelector = NULL;
    subReq.cachePolicy = ASIDoNotReadFromCacheCachePolicy;
    tagReq.cachePolicy = ASIDoNotReadFromCacheCachePolicy;
    tagReq.didReceiveResponseHeadersSelector = @selector(receivedResponseHeader:);
    [queue addOperation:tagReq];
    [queue addOperation:subReq];
    
    self.requestQueue = queue;
    
    [self postNotification:NOTIFICATION_BEGIN_UPDATEREADERSTRUCTURE object:nil];
    __block typeof(self) blockSelf = self;
    
    [[GoogleAuthManager shared] authRequests:queue.operations completionBlock:^(NSError* error){
        if (error == nil){
            blockSelf.reportError = nil;
            [queue go];
        }else{ 
            [blockSelf postNotification:NOTIFICAITON_FAILED_UPDATEREADERSTRUCTURE object:nil];
            NSLog(@"auth log: %@", [error localizedDescription]);
            blockSelf.reportError = error;
            [blockSelf performCallBack];
        }
    }];
    
//    [[GoogleAuthManager shared] authRequest:tagReq completionBlock:^(NSError* error){
//        if (error == nil){
//            [[GoogleAuthManager shared] authRequest:subReq];
//            blockSelf.reportError = nil;
//            [blockSelf.requestQueue go];
//        }else{ 
//            NSLog(@"auth log: %@", [error localizedDescription]);
//            blockSelf.reportError = error;
//            [blockSelf performCallBack];
//        }
//    }];
}

-(void)refreshSubscriptionList{
    [self clearAllRequests];
    self.request = [self requestForSubscriptionList];
    self.request.didFinishSelector = @selector(requestFinished:);
    self.request.didFailSelector = @selector(requestFailed:);
    __block typeof(self) blockSelf = self;
    [[GoogleAuthManager shared] authRequest:self.request completionBlock:^(NSError* error){
        if (error == nil){
            [blockSelf.request startAsynchronous];
        }
    }];
}

-(ASIHTTPRequest*)requestForTagList{
    
    NSString* taglistString = [URI_PREFIX_API stringByAppendingString:API_LIST_TAG];
    URLParameterSet* tagParam = [[URLParameterSet alloc] init];
    [tagParam setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    ASIHTTPRequest* tagRequest = [self requestWithURL:[self fullURLFromBaseString:taglistString] parameters:tagParam APIType:API_LIST]; 
    tagRequest.didStartSelector = @selector(tagRequestStarted:);
    tagRequest.didFinishSelector = @selector(tagRequestFinished:);
    
    return tagRequest;
}

-(ASIHTTPRequest*)requestForSubscriptionList{
    NSString* sublistString = [URI_PREFIX_API stringByAppendingString:API_LIST_SUBSCRIPTION];
    URLParameterSet* subParam = [[URLParameterSet alloc] init];
    [subParam setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    
    ASIHTTPRequest* subRequest = [self requestWithURL:[self fullURLFromBaseString:sublistString] parameters:subParam APIType:API_LIST];
    subRequest.didFinishSelector = @selector(subRequestFinished:);
    subRequest.didStartSelector = @selector(subRequestStarted:);
    
    return subRequest;
}

-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    if (_userID == nil){
        _userID = [responseHeaders objectForKey:@"X-Reader-User"];
    }
}

-(void)subRequestStarted:(ASIHTTPRequest*)request{
    DebugLog(@"subscriptions list request started");
    [self postNotification:NOTIFICATION_BEGIN_UPDATESUBSCRIPTIONLIST object:nil];
}

-(void)subRequestFinished:(ASIHTTPRequest*)request{
    NSArray* subs = [[NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingAllowFragments error:nil] objectForKey:@"subscriptions"];
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
    NSArray* tags = [[NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingAllowFragments error:nil] objectForKey:@"tags"];
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
    _needRefreshReaderStructure = NO;
    [[self class] saveReaderStructure];
    [self performCallBack];
    [self postNotification:NOTIFICAITON_END_UPDATEREADERSTRUCTURE object:nil];
    [self refreshUnreadCount];
}

-(void)tagAndSubRequestFailed:(ASIHTTPRequest*)request{
    DebugLog(@"%@", [request.error localizedDescription]);
    self.reportError = request.error;
    [self performCallBack];
    [self postNotification:NOTIFICAITON_FAILED_UPDATEREADERSTRUCTURE object:nil];
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

+(void)removeStoredReaderData{
    NSFileManager* manager = [NSFileManager defaultManager];
    NSError* error = nil;
    NSString* filePath = [self filePathWithName:@"taglist"];
    [manager removeItemAtPath:filePath error:&error];
    filePath = [self filePathWithName:@"sublist"];
    [manager removeItemAtPath:filePath error:&error];
    filePath = [self filePathWithName:@"unreadcount"];
    [manager removeItemAtPath:filePath error:&error];
    
    [UniversalSubList removeAllObjects];
    [UniversalTagList removeAllObjects];
    [UniversalUnreadCount removeAllObjects];
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
    [self requestFeedWithIdentifier:identifer count:count startFrom:date exclude:excludeString continuation:continuationStr forceRefresh:refresh needAuth:needAuth priority:NSOperationQueuePriorityNormal];
}

-(void)requestFeedWithIdentifier:(NSString*)identifer
                           count:(NSNumber*)count 
                       startFrom:(NSDate*)date 
                         exclude:(NSString*)excludeString 
                    continuation:(NSString*)continuationStr
                    forceRefresh:(BOOL)refresh 
                        needAuth:(BOOL)needAuth 
                        priority:(NSOperationQueuePriority)priority{
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
    self.request.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
    self.request.delegate = self;
    [self.request setQueuePriority:priority];
    
    if (needAuth){
        [[GoogleAuthManager shared] authRequest:_request completionBlock:^(NSError* error){
            if (error == nil){
                [_request startAsynchronous];
            }
        }];
    }else{
        [self.request startAsynchronous];
    }
}

-(void)getStreamDetails:(NSString*)streamID{
    URLParameterSet* parameters = [[URLParameterSet alloc] init];
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
    
    URLParameterSet* parameters = [[URLParameterSet alloc] init];
    
    for (NSDictionary* ID in IDArray){
        [parameters setParameterForKey:CONTENTS_ARGS_ID withValue:[ID objectForKey:@"id"]];
        [parameters setParameterForKey:CONTENTS_ARGS_IT withValue:@"0"];
    }
    
    ASIFormDataRequest* request = [self requestWithURL:[self fullURLFromBaseString:API_STREAM_ITEMS_CONTENTS] parameters:parameters APIType:API_EDIT];

    [self clearAllRequests];
    self.request = request;
    [[GoogleAuthManager shared] authRequest:self.request completionBlock:^(NSError* error){
        if (error == nil){
            [self.request startAsynchronous];
        }
    }];
}

-(void)searchArticlesWithKeywords:(NSString*)keywords{
    URLParameterSet* paramSet = [[URLParameterSet alloc] init];
    [paramSet setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    [paramSet setParameterForKey:SEARCH_ARGS_NUMBER withValue:[NSNumber numberWithInt:300]];
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
	URLParameterSet* paramSet = [[URLParameterSet alloc] init];
	[paramSet setParameterForKey:ATOM_ARGS_COUNT withValue:@"99999"];
	[paramSet setParameterForKey:LIST_ARGS_OUTPUT withValue:OUTPUT_JSON];
    void(^completionBlock)(ASIHTTPRequest*) = ^(ASIHTTPRequest* request){
        _needRefreshRecommendation = NO;
    };
    self.requestInternalCompletionBlock = completionBlock;
    
    [self listRequestWithURL:[self fullURLFromBaseString:url] parameters:paramSet];
}

-(void)requestRelatedSubscriptions:(NSString*)streamID{
    if (streamID.length == 0){
        return;
    }
    NSString* url = [URI_PREFIX_API stringByAppendingString:API_LIST_RELATED];
	URLParameterSet* paramSet = [[URLParameterSet alloc] init];
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
	URLParameterSet* paramSet = [[URLParameterSet alloc] init];
	
	[paramSet setParameterForKey:EDIT_ARGS_FEED withValue:streamID];//add feed URI
    
    [self clearAllRequests];
    self.request = [self requestWithURL:[self fullURLFromBaseString:url] parameters:paramSet APIType:API_EDIT];
    __block typeof(self) blockSelf = self;
    [self.request setCompletionBlock:^{
        NSLog(@"mark all as read succeeded");
        NSArray* items = [[[blockSelf class] itemsForFeed] objectForKey:streamID];
        [items makeObjectsPerformSelector:@selector(markAsRead)];
        [blockSelf performCallBack];
        [blockSelf performSelectorOnMainThread:@selector(refreshUnreadCount) withObject:blockSelf waitUntilDone:NO];
    }];
    [self.request setFailedBlock:^{
        NSLog(@"mark all as read failed");
        [blockSelf performCallBack];
    }];
    
    [self addTokenToRequest:_request completionBlock:^(NSError* error){
        if (error){
            [blockSelf performCallBack];
        }else{
            
            [[GoogleAuthManager shared] authRequest:blockSelf.request completionBlock:^(NSError* error){
                if (error == nil){
                    [blockSelf.request startAsynchronous];
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
    
    URLParameterSet* paramSet = [[URLParameterSet alloc] init];
    [paramSet setParameterForKey:EDIT_ARGS_FEED withValue:streamID];
    [paramSet setParameterForKey:EDIT_ARGS_RECOMMENDATION_ACTION withValue:action];
    self.request = [self requestWithURL:[self fullURLFromBaseString:url] parameters:paramSet APIType:API_EDIT];
    __block typeof(self) blockSelf = self;
    [self addTokenToRequest:self.request completionBlock:^(NSError* error){
        if (error == nil){
            [[GoogleAuthManager shared] authRequest:blockSelf.request completionBlock:^(NSError* error){
                [blockSelf.request startAsynchronous];
            }];
        }
    }];
}

-(void)addSubscription:(NSString*)streamID 
             withTitle:(NSString*)title 
                 toTag:(NSString*)tag{
    [self editSubscription:streamID action:@"subscribe" tagToAdd:tag tagToRemove:nil newName:title completionBlock:^(ASIHTTPRequest* request){
        _needRefreshReaderStructure = YES;
        _needRefreshRecommendation = YES;
        GRSubscription* sub = [[GRSubscription alloc] init];
        sub.ID = streamID;
        sub.title = title;
        [UniversalSubList setObject:sub forKey:streamID];
    }];
}

-(void)removeSubscription:(NSString*)subscription{
    [self editSubscription:subscription action:@"unsubscribe" tagToAdd:nil tagToRemove:nil newName:nil completionBlock:^(ASIHTTPRequest* request){
         _needRefreshRecommendation = YES;
        [UniversalSubList removeObjectForKey:subscription];
        [GoogleReaderClient saveReaderStructure];
    }];
}

-(void)renameSubscription:(NSString*)subscription 
              withNewName:(NSString*)newName{
    [self editSubscription:subscription action:@"rename" tagToAdd:nil tagToRemove:nil newName:newName completionBlock:^(ASIHTTPRequest* request){
        _needRefreshReaderStructure = YES;
        GRSubscription* sub = [GoogleReaderClient subscriptionWithID:subscription];
        sub.title = newName;
        [GoogleReaderClient saveReaderStructure];
    }]; 
}

-(void)editSubscription:(NSString*)subscription 
               tagToAdd:(NSString*)tagToAdd
            tagToRemove:(NSString*)tagToRemove{
    [self editSubscription:subscription action:@"edit" tagToAdd:tagToAdd tagToRemove:tagToRemove newName:nil completionBlock:^(ASIHTTPRequest* request){
        _needRefreshReaderStructure = YES;
        GRSubscription* sub = [GoogleReaderClient subscriptionWithID:subscription];
        NSString* newTag = tagToAdd;
        if (newTag.length > 0){
            if ([newTag hasPrefix:@"user/"] == NO){
                _needRefreshReaderStructure = YES;
                newTag = [NSString stringWithFormat:@"user/%@/label/%@", _userID, tagToAdd];
            }
            [sub.categories addObject:newTag];
            
            GRTag* tag = [GoogleReaderClient tagWithID:newTag];
            if (!tag){
                tag = [[GRTag alloc] init];
                tag.ID = newTag;
                tag.label = [[newTag componentsSeparatedByString:@"/"] lastObject];
                @synchronized(UniversalTagList){
                    [UniversalTagList setObject:tag forKey:tag.ID];
                }
            }
        }
        
        if (tagToRemove.length > 0){
            [sub.categories removeObject:tagToRemove];
        }
        [GoogleReaderClient saveReaderStructure];
    }];
}

-(void)editSubscription:(NSString *)subscription action:(NSString*)action tagToAdd:(NSString *)tagToAdd tagToRemove:(NSString *)tagToRemove newName:(NSString*)newName completionBlock:(void(^)(ASIHTTPRequest*))block{
    
    NSAssert(action.length > 0, @"action of subscrition edit should not be nil!");
    URLParameterSet* paramSet = [[URLParameterSet alloc] init];
    
    if (tagToAdd.length != 0){
        if ([tagToAdd hasPrefix:@"user/"] == NO){
            tagToAdd = [NSString stringWithFormat:@"user/%@/label/%@", _userID, tagToAdd];
        }
        [paramSet setParameterForKey:EDIT_ARGS_ADD withValue:tagToAdd];//tag name to add
    };
    if (tagToRemove.length != 0){
        [paramSet setParameterForKey:EDIT_ARGS_REMOVE withValue:tagToRemove];
    };
    if (newName.length != 0){
        [paramSet setParameterForKey:EDIT_ARGS_TITLE withValue:newName];
    }
    [paramSet setParameterForKey:EDIT_ARGS_FEED withValue:subscription];//add feed URI
	[paramSet setParameterForKey:EDIT_ARGS_ACTION withValue:action];//add API action. edit, subscribe, unsubscribe
    
    //get complete feed URI in Google Reader
	NSString* urlString = [URI_PREFIX_API stringByAppendingString:API_EDIT_SUBSCRIPTION];
	
    self.request = [self requestWithURL:[self fullURLFromBaseString:urlString] 
                             parameters:paramSet
                                APIType:API_EDIT];
    self.request.didFinishSelector = @selector(subscriptionEditFinished:);
    self.requestInternalCompletionBlock = block;
    
    __block typeof(self) blockSelf = self;
    [self addTokenToRequest:self.request completionBlock:^(NSError* error){
        if (error == nil){
            [[GoogleAuthManager shared] authRequest:blockSelf.request completionBlock:^(NSError* error){
                [blockSelf.request startAsynchronous];
            }];
        }
    }];
}

-(void)subscriptionEditFinished:(ASIHTTPRequest*)request{
    if ([self isResponseOK] == YES){
        [self performRequestInternalCompletionBlock:request];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NEED_UPATEREADERSTRUCTURE object:nil];
    }
    [self performCallBack];
}

#pragma mark - request delegate
-(void)requestStarted:(ASIHTTPRequest*)request{
    DebugLog(@"request started");
}

-(void)requestFailed:(ASIHTTPRequest*)request{
    [self performCallBack];
}

-(void)requestFinished:(ASIHTTPRequest*)request{
    [self performRequestInternalCompletionBlock:request];
    [self performCallBack];
}

#pragma mark - getter and setter
-(NSString*)responseString{
    if (self.request.didUseCachedResponse){
        DebugLog(@"this request use cache");
    }
    return self.request.responseString;
}

-(NSData*)responseData{
    return self.request.responseData;
}

-(id)responseJSONValue{
    
    return [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:nil];

}

-(GRFeed*)responseFeed{
    GRFeed* feed = [GRFeed objWithJSON:self.responseJSONValue];
    if (feed == nil){
        DebugLog(@"%@", self.responseString);
    }
    if (self.request.didUseCachedResponse == NO && feed){
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

-(BOOL)didUseCachedData{
    return [self.request didUseCachedResponse];
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
    
    return [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}

-(BOOL)isResponseOK{
    DebugLog(@"response string is %@", self.request.responseString);
    return [self.request.responseString compare:@"ok" options:NSCaseInsensitiveSearch] == NSOrderedSame;
}

-(NSError*)error{
    return (self.reportError != nil)?self.reportError:self.request.error;
}

#pragma mark - url parameters

-(URLParameterSet*)compileParameterSetWithCount:(NSNumber*)count 
									  startFrom:(NSDate*)date 
										exclude:(NSString*)excludeString 
                                   continuation:(NSString*)continuationStr {
	URLParameterSet* parameterSet = parameterSet = [[URLParameterSet alloc] init];;
	
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
        
        for (ParameterPair* pair in [parameters allPairs]){
            [(ASIFormDataRequest*)request addPostValue:pair.value forKey:pair.key];
        }
        URLParameterSet* additionalParameters = [[URLParameterSet alloc] init];
        
        [additionalParameters setParameterForKey:EDIT_ARGS_CLIENT withValue:CLIENT_IDENTIFIER];
//        [additionalParameters setParameterForKey:EDIT_ARGS_SOURCE withValue:EDIT_ARGS_SOURCE_RECOMMENDATION];
        
        NSString* temp = [request.url absoluteString];
        temp = [temp stringByAppendingString:@"?"];
        temp = [temp stringByAppendingString:[additionalParameters parameterString]];
        [request setURL:[NSURL URLWithString:temp]];
        
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
    
//    request.timeOutSeconds = 5;
    request.shouldAttemptPersistentConnection = NO;
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
     
-(void)editItem:(NSString*)itemID 
            addTag:(NSString*)tagToAdd 
         removeTag:(NSString*)tagToRemove{
    
    NSString* url = [URI_PREFIX_API stringByAppendingString:API_EDIT_TAG2];
	//Prepare parameters
	URLParameterSet* paramSet = [[URLParameterSet alloc] init];
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
                    [request startAsynchronous];
                }
            }];
        }
    }];
}

//add token if only needed
-(void)addTokenToRequest:(id)request completionBlock:(void(^)(NSError* error))block{
    if ([request isKindOfClass:[ASIFormDataRequest class]] == NO){
        return;
    }
    
    NSString* token = [[self class] token];
    NSMutableArray* addTokenQueue = [[self class] addTokenQueue];
    if (token == nil){
        @synchronized(addTokenQueue){
            FetchTokenArg* arg = [[FetchTokenArg alloc] init];
            arg.request = request;
            arg.completionHandler = block;
            
            [addTokenQueue addObject:arg];
        
            [self startFetchToken];
        }
                
    }else{
        [request addPostValue:token forKey:EDIT_ARGS_TOKEN];
        if (block){
            block(nil);
        }
    }
}

-(void)startFetchToken{
    if ([[GoogleReaderClient tokenFetchingLock] tryLock] == NO){
        return;
    }
//    _startFetchToken = YES;
    NSString* urlString = [URI_PREFIX_API stringByAppendingString:API_TOKEN];
    urlString = [GOOGLE_SCHEME_SSL stringByAppendingString:urlString];
    
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.cachePolicy = ASIDoNotReadFromCacheCachePolicy;
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
         [[GoogleReaderClient tokenFetchingLock] unlock];
//        _startFetchToken = NO;
    }];
    
    [request setFailedBlock:^{
        [[GoogleReaderClient tokenFetchingLock] unlock];
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
//        _startFetchToken = NO;
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
    
    if (self.delegateCompletionHandler){
        GoogleReaderCompletionHandler handler = self.delegateCompletionHandler;
        handler([self error]);
        self.delegateCompletionHandler = nil;
    }
}

-(void)performRequestInternalCompletionBlock:(ASIHTTPRequest*)request{
    if (self.requestInternalCompletionBlock){
        void(^block)(ASIHTTPRequest*) = self.requestInternalCompletionBlock;
        block(request);
        self.requestInternalCompletionBlock = nil;
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
