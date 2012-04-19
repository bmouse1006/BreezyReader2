//
//  GRDataManager.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "NSObject+Notifications.h"
#import "GRDataManager.h"
#import "GRRecFeed.h"
#import "GoogleAuthManager.h"
#import "ASIHTTPRequest.h"

@implementation GRDataManager

@synthesize tagDict = _tagDict;
@synthesize subDict = _subDict;
@synthesize unreadCount = _unreadCount;
@synthesize processedTagDict = _processedTagDict;
@synthesize processedSubDict = _processedSubDict;
@synthesize favoriteSubDict = _favoriteSubDict;
@synthesize recFeedList = _recFeedList;
@synthesize cache = _cache;
@synthesize feedPool = _feedPool;
@synthesize itemPool = _itemPool;
@synthesize grController = _grController;
@synthesize feedOperationQueue = _feedOperationQueue;
@synthesize editOperationQueue = _editOperationQueue;

@synthesize runningOperationKeys = _runningOperationKeys;

@synthesize errorHappened = _errorHappened;
@synthesize grError = _grError;

@synthesize lastSubscribedStreamID = _lastSubscribedStreamID;

static GRDataManager *readerDM = nil;

+(void)didReceiveMemoryWarning{
	[[GRDataManager shared] clearMemory];
}

-(void)refreshRecFeedsList{
    [self performSelectorInBackground:@selector(taskRefreshRecFeedsList) withObject:nil];
}

-(void)taskRefreshRecFeedsList{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSDictionary* jsonObj = [self.grController allRecommendationFeeds];
	
	NSArray* jsonRecFeeds = [jsonObj objectForKey:@"recs"];
	
	NSMutableArray* feeds = [NSMutableArray arrayWithCapacity:0];
	
	for (NSDictionary* obj in jsonRecFeeds){
		GRRecFeed* recFeed = [GRRecFeed recFeedsWithJSONObject:obj];
		[feeds addObject:recFeed];
	}
	
	self.recFeedList = feeds;
	
	[self sendNotification:NOTIFICATION_ALLRECOMMENDATIONS withUserInfo:nil];
	
	[pool release];
}

//makr all items in one sub as read
-(void)markAllAsRead:(GRSubscription*)sub waitUtilDone:(BOOL)wait{

	if (wait) {
		[self taskMarkAllAsRead:sub];
	}else{
        NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(taskMarkAllAsRead:) object:sub];
        [self.editOperationQueue addOperation:operation];
        [operation release];
	}
}

-(void)taskMarkAllAsRead:(GRSubscription*)sub{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSString* result = [self.grController markAllAsReadForSubscription:sub.ID];
	
	if ([result isEqualToString:@"ok"]) {
		[self taskSyncReaderStructure];
		GRFeed* feed = [self feedWithSubID:[sub keyString]];
		GRFeed* continuedFeed = nil;
		if (feed.gr_continuation){
			continuedFeed = [self feedWithSubID:[[sub keyString] stringByAppendingString:feed.gr_continuation]];
		}
		[feed.items makeObjectsPerformSelector:@selector(markAsRead)];
		[continuedFeed.items makeObjectsPerformSelector:@selector(markAsRead)];
	}	
	
	[pool release];
}

-(GRTag*)getUpdatedGRTag:(NSString*)tagID{
	return [self.processedTagDict objectForKey:tagID];
}

-(GRSubscription*)getUpdatedGRSub:(NSString*)subID{
	return [self.processedSubDict objectForKey:subID];
}

-(void)notifyErrorHappened{
	DebugLog(@"Error happened");
    DebugLog(@"Error is %@", [self.grError localizedDescription]);
	[self sendNotification:GRERRORHAPPENED withUserInfo:self.grError.userInfo];
}


-(void)markItemsAsRead:(NSArray*)items{
	[items retain];
	for (GRItem* item in items){
		if (![item isReaded]){
			[self markItemAsRead:item];
		}
	}
	[items release]; 
}

-(void)markItemAsRead:(GRItem*)item{
	NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self 
																			selector:@selector(taskMarkItemAsRead:) object:item];
	[self.editOperationQueue addOperation:operation];
	[operation release];
}

-(void)taskMarkItemAsRead:(GRItem*)item{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSString* readTag = [ATOM_PREFIX_STATE_GOOGLE stringByAppendingString:ATOM_STATE_READ];
	[self.grController editItem:item.ID
						 addTag:readTag
					  removeTag:nil];
    
    [item markAsRead];
	//notify that this item has been read
	NSString* name = [item.ID stringByAppendingString:@"read"];
    [self sendNotification:name withUserInfo:nil];
	
	[pool release];
}

-(GRFeed*)feedWithSubID:(NSString*)subID{
	return [self.feedPool objectForKey:subID];
}

-(GRItem*)itemWithID:(NSString *)itemID{
	return [self.itemPool objectForKey:itemID];
}

-(void)refreshFeedWithSub:(GRSubscription*)sub manually:(BOOL)manually{
	
	//if it's not refreshed manually and later than 30min after last updated, than do nothing
	GRFeed* feed = [self feedWithSubID:[sub keyString]];
	if (manually || ([[NSDate date] timeIntervalSinceDate:feed.refreshed] > 1800 || !feed)){
		//time interval is bigger than 30min or no such feed, refresh
		NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(taskRefreshFeed:) object:sub];
		[self.feedOperationQueue addOperation:operation];
		[operation release];
	}
}

-(void)continuingFeed:(GRFeed*)feed{
	NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(taskContinuingFeed:) object:feed];
	[self.feedOperationQueue addOperation:operation];
	[operation release];
}

-(void)taskContinuingFeed:(GRFeed*)feed{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSString* feedKey = [[feed keyString] stringByAppendingString:feed.gr_continuation];
	
	GRFeed* continuedfeed = [self feedWithSubID:feedKey];
	
	if (!continuedfeed){
	
		NSNumber* defaultItemCount = [NSNumber numberWithInt:[UserPreferenceDefine defaultNumberOfDownloaderItems]];//read default item
		
		NSString* excludeLabel = nil;
		
		continuedfeed = [self.grController getFeedForID:feed.subscriptionID
							  count:defaultItemCount
						  startFrom:nil
							exclude:excludeLabel
					   continuation:feed.gr_continuation];
		
		if (self.errorHappened == YES){
			[self notifyErrorHappened];
			[pool release];
			return;
		}
		
		[self.feedPool setObject:continuedfeed forKey:[[feed keyString] stringByAppendingString:feed.gr_continuation]];
	}
	
	NSDictionary* userInfo = [NSDictionary dictionaryWithObject:@"YES" forKey:CONTINUEDFEEDKEY];
	
	[self sendNotification:[feed keyString] withUserInfo:userInfo];
	[pool release];
}

-(void)taskRefreshFeed:(GRSubscription*)subscription{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSNumber* defaultItemCount = [NSNumber numberWithInt:[UserPreferenceDefine defaultNumberOfDownloaderItems]];//default item count
	[self sendNotification:[BEGANFEEDUPDATING stringByAppendingString:[subscription keyString]] withUserInfo:nil];
	
	NSString* excludeLabel = nil;
	if (subscription.isUnreadOnly){
		excludeLabel = [ATOM_PREFIX_STATE_GOOGLE stringByAppendingString:ATOM_STATE_READ];
	}
	
	GRFeed* feed = [self.grController getFeedForID:[subscription ID] 
											 count:defaultItemCount 
										 startFrom:nil 
										   exclude:excludeLabel 
									  continuation:nil];//read online
	if (self.errorHappened == YES){
		[self notifyErrorHappened];
		[pool release];
		return;
	}
	NSString* subKey = [subscription keyString];
	GRFeed* origFeed = [self.feedPool objectForKey:subKey];
	if (!origFeed){//if this feed is not cached before
		feed.subscriptionID = [subscription ID];
		if (feed){
			[self.feedPool setObject:feed forKey:subKey];
		}
	}else {//if this feed has been cached, than merge them together
		origFeed = [origFeed mergeWithFeed:feed continued:NO];
		if (origFeed){
			[self.feedPool setObject:origFeed forKey:subKey];
		}
	}

	//notify that the feed with feedID has been updated
	[self sendNotification:[ENDFEEDUPDATING stringByAppendingString:subKey] withUserInfo:nil];
	[pool release];
	
}

-(NSArray*)getSubscriptionListWithTag:(NSString*)tagID{
	id cachedResult = [self.cache objectForKey:tagID];
	if (cachedResult)
		return cachedResult;
	
	NSMutableArray* tempList = nil;
	
	if (tagID.length == 0){
		tempList = [NSMutableArray arrayWithArray:[self getSubscriptionListWithoutTag]];
	}else{
		tempList = [NSMutableArray arrayWithObjects:0];
		@synchronized(_processedSubDict){
			GRTag* tag = [self.processedTagDict objectForKey:tagID];
//			for (NSString* subID in tag.subscriptions){
//				[tempList addObject:[self.processedSubDict objectForKey:subID]];
//			}
		}
	}
	
	if (tempList){
		[self.cache setObject:tempList forKey:tagID];
	}
	return tempList;
}

-(NSArray*)getSubscriptionListWithoutTag{
	NSString* key = @"";
	id cachedResult = [self.cache objectForKey:key];
	if (cachedResult)
		return cachedResult;
	
	NSMutableArray* tempList = [NSMutableArray arrayWithObjects:0];
	@synchronized(_processedSubDict){
		NSArray* subs = [self.processedSubDict allValues];
		for(GRSubscription* sub in subs){
			if (!sub.categories || [sub.categories count] == 0)
				[tempList addObject:sub];
		}
	}
	
	[self.cache setObject:tempList forKey:key];
	return tempList;
}

-(NSArray*)getAllSubscriptions{
	return [self.processedSubDict allValues];
}

-(NSArray*)getLabelList{
	return [self getTagListContainsText:@"/label/"];
}

-(NSArray*)getStateList{
	return [self getTagListContainsText:@"/state/"];
}

-(NSArray*)getTagListContainsText:(NSString*)str{
	NSMutableArray* tempArray = [NSMutableArray array];
	
	NSArray* allTags = [self.processedTagDict allValues];
	
	for(GRTag* tag in allTags){
		NSRange find = [tag.ID rangeOfString:str];
		if (find.location != NSNotFound)
			[tempArray addObject:tag];
	}
	
	return tempArray;
}

-(NSDictionary*)getUnreadCount{
	NSString* key = @"unreadCount";
	id cachedResult = [self.cache objectForKey:key];
	if (cachedResult)
		return cachedResult;
	
	NSMutableDictionary* tempDic = [NSMutableDictionary dictionaryWithCapacity:0];
	
	NSArray* countList = [self.unreadCount objectForKey:@"unreadcounts"];
	for (NSDictionary* count in countList) {
		[tempDic setObject:count forKey:[count objectForKey:@"id"]];
	}
	
	if (tempDic){
		[self.cache setObject:tempDic forKey:key];
	}

	return tempDic;
}

-(NSArray*)getFavoriteSubList{
//	NSMutableArray* keys = [[NSMutableArray alloc] init];
//	[keys addObjectsFromArray:[self.favoriteSubDict allKeys]];
//	[keys sortUsingSelector:@selector(compare:)];
	return nil;
}

-(NSArray*)getRecFeedList{
	return self.recFeedList;
}

-(id)init{
	if (self = [super init]){
		//register notification
        [self registerNotifications];
		//add more init code here
		self.cache = [NSMutableDictionary dictionaryWithCapacity:0];
		self.feedPool = [NSMutableDictionary dictionaryWithCapacity:0];//先不考虑保存的问题，每次App重新打开后都重新载入
		self.runningOperationKeys = [NSMutableSet setWithCapacity:0];
		//初始化 GR Controller and Operation Queue;
		GoogleReaderController* tempController = [[GoogleReaderController alloc] initWithDelegate:self];
		self.grController = tempController;
		[tempController release];
		self.feedOperationQueue = [[[NSOperationQueue alloc] init] autorelease];
		self.editOperationQueue = [[[NSOperationQueue alloc] init] autorelease];
		self.recFeedList = [NSArray array];
		[self readerDMSetup];
	}
	return self;
}

-(void)readerDMSetup{
	//判断是否已经登录
	if ([[GoogleAuthManager shared] canAuthorize]){
		//先从存储的文件里面读
		[self readListFromFile];
	}else {
		DebugLog(@"We need login!!");
		[self sendNotification:LOGINNEEDED withUserInfo:nil];
	//发出需要登录的notification
	}

}

-(void)reloadData{
	[self readerDMSetup];
	[self syncReaderStructure];
} 

-(void)reloadData_new{
    [self readerDMSetup];
    [self syncReaderStructure_new];
}

-(void)syncReaderStructure{
	NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(taskSyncReaderStructure) object:nil];
	[self.editOperationQueue addOperation:operation];
	[operation release];
}

-(void)taskSyncSubscriptionsAndTags{
	//auto release pool is needed for new thread
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
	NSDictionary* tempSubList = [self.grController allSubscriptions];
	NSDictionary* tempTagList = [self.grController allTags];	
	if (self.errorHappened == YES || tempSubList == nil || tempTagList == nil){
		[self notifyErrorHappened];
		[pool release];
		return;
	}
	
	if (![self.subDict isEqualToDictionary:tempSubList] || ![self.tagDict isEqualToDictionary:tempTagList]){
		self.subDict = tempSubList;
		self.tagDict = tempTagList;
		[self.cache removeAllObjects];
		[self buildProcessedList];
		[self sendNotification:TAGORSUBCHANGED withUserInfo:nil];
	}
	
	[pool release];
}

-(void)syncReaderStructure_new{
    ASIHTTPRequest* request_sub = [[GoogleReaderController controller] requestForAllSubscriptions];
    ASIHTTPRequest* request_tag = [[GoogleReaderController controller] requestForAllTags];
	
    DebugLog(@"url of request for sub is %@", request_sub.url);
    DebugLog(@"url of request for tag is %@", request_tag.url);
    
    [[GoogleAuthManager shared] authRequest:request_sub completionBlock:^(NSError* error){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (!error){
                [self sendNotification:BEGANSYNCDATA withUserInfo:nil];
                [[GoogleAuthManager shared] authRequest:request_tag];
                [request_sub startSynchronous];
                [request_tag startSynchronous];
                NSDictionary* tempSubList = [request_sub.responseString JSONValue];;
                NSDictionary* tempTagList = [request_tag.responseString JSONValue];	
                if (![self.subDict isEqualToDictionary:tempSubList] || ![self.tagDict isEqualToDictionary:tempTagList]){
                    self.subDict = tempSubList;
                    self.tagDict = tempTagList;
                    [self.cache removeAllObjects];
                    [self buildProcessedList];
                    [self sendNotification:TAGORSUBCHANGED withUserInfo:nil];
                    [self writeListToFile];
                }
                [self sendNotification:ENDSYNCDATA withUserInfo:nil];
                [self syncUnreadCount_new];
            }  
        });
    }];
}

-(void)syncUnreadCount_new{
    ASIHTTPRequest* request = [[GoogleReaderController controller] requestForUnreadCount];
    
    [[GoogleAuthManager shared] authRequest:request completionBlock:^(NSError* error){
        if (error == nil){
            [request setCompletionBlock:^{
                NSDictionary* tempUnreadCount = [request.responseString JSONValue];	
                
                BOOL changed = ![self.unreadCount isEqualToDictionary:tempUnreadCount];
                
                if (changed){
                    self.unreadCount = tempUnreadCount;
                    [self updateUnreadCountToProcessedList];
                    [self sendNotification:UNREADCOUNTCHANGED withUserInfo:nil];
                }
            }];
            [request startAsynchronous]; 
        }
    }];
}

-(void)syncUnreadCount{
	NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(taskSyncUnreadCount) object:nil];
	[self.editOperationQueue addOperation:operation];
	[operation release];
}

-(void)taskSyncUnreadCount{
	//auto release pool is needed for new thread
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	NSDictionary* tempUnreadCount = [self.grController unreadCount];	
	if (self.errorHappened == YES){
		[self notifyErrorHappened];
		[pool release];
		return;
	}
	
	[tempUnreadCount retain];

	BOOL changed = NO;
	if (![self.unreadCount isEqualToDictionary:tempUnreadCount]){
		changed = YES;	
	}
	
	self.unreadCount = tempUnreadCount;
	[self updateUnreadCountToProcessedList];

	if (changed){
		[self sendNotification:UNREADCOUNTCHANGED withUserInfo:nil];
	}
	
	[tempUnreadCount release];
	
	[pool release];
}

-(void)taskSyncReaderStructure{
	//auto release pool is needed for new thread
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	//notify began sync data
	[self sendNotification:BEGANSYNCDATA withUserInfo:nil];
	
	[self taskSyncSubscriptionsAndTags];
	[self taskSyncUnreadCount];
    [self writeListToFile];

	[self sendNotification:ENDSYNCDATA withUserInfo:nil];
	[pool release];
}

-(void)didReceiveErrorWhileRequestingData:(NSError *)error{
	self.errorHappened = YES;
	self.grError = error;
	//unknown error happened, try to relogin
	[self.feedOperationQueue cancelAllOperations];
}

-(void)didSuccessFinishedDataReceive:(NSURLResponse*)response{
	self.errorHappened = NO;
	self.grError = nil;
}

#pragma mark - notification

-(void)registerNotifications{
    NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self
           selector:@selector(successfullySubscribed:)
               name:NOTIFICATION_SUBSCRIBEFEED_SUCCESS
             object:nil];
    [dc addObserver:self
           selector:@selector(userSignedIn:) 
               name:kGTMOAuth2UserSignedIn
             object:self];
}

-(void)sendNotification:(NSString*)name withUserInfo:(NSDictionary*)userInfo{

	DebugLog(@"sending notification key is %@", name);
	[userInfo retain];
	NSNotification* notification = [NSNotification notificationWithName:name object:self userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
	[userInfo release];
}

-(void)userSignedIn:(NSNotification*)notification{
    //removed saved file
    [self removeSavedFiles];
//    //start sync reader structers - tag, sub and unread count
//    [self syncReaderStructure];
}

#pragma mark - write and read config with file
//init list from file while initializing
-(void)readListFromFile{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	if (!documentsDirectory) {
		DebugLog(@"Documents directory not found!");
		return;
	}
	NSString *thePath = [documentsDirectory stringByAppendingPathComponent:TAGLISTFILE];
	self.tagDict = [NSDictionary dictionaryWithContentsOfFile:thePath];
	thePath = [documentsDirectory stringByAppendingPathComponent:SUBSCRIPTIONLISTFILE];
	self.subDict = [NSDictionary dictionaryWithContentsOfFile:thePath];
	thePath = [documentsDirectory stringByAppendingPathComponent:UNREADCOUNTFILE];
	self.unreadCount = [NSDictionary dictionaryWithContentsOfFile:thePath];
	thePath = [documentsDirectory stringByAppendingPathComponent:FAVORITELISTFILE];
	self.favoriteSubDict = [NSMutableDictionary dictionaryWithContentsOfFile:thePath];
	[self buildProcessedList];
	[self updateUnreadCountToProcessedList];
//	thePath = [documentsDirectory stringByAppendingString:CACHEFILE];
//	self.cache = [NSMutableDictionary dictionaryWithContentsOfFile:thePath];
	DebugLog(@"read done!!");
}

//save list to files when application quit
-(void)writeListToFile{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	if (!documentsDirectory) {
		DebugLog(@"Documents directory not found!");
		return;
	}
	NSString *thePath = [documentsDirectory stringByAppendingPathComponent:TAGLISTFILE];
	[self.tagDict writeToFile:thePath atomically:YES];
	thePath = [documentsDirectory stringByAppendingPathComponent:SUBSCRIPTIONLISTFILE];
	[self.subDict writeToFile:thePath atomically:YES];
	thePath = [documentsDirectory stringByAppendingPathComponent:UNREADCOUNTFILE];
	[self.unreadCount writeToFile:thePath atomically:YES];
	thePath = [documentsDirectory stringByAppendingPathComponent:FAVORITELISTFILE];
	[self.favoriteSubDict writeToFile:thePath atomically:YES];
//	thePath = [documentsDirectory stringByAppendingString:CACHEFILE];
//	[self.cache writeToFile:thePath atomically:YES];
	DebugLog(@"write done!!");
}
	 
-(void)removeSavedFiles{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	if (!documentsDirectory) {
		DebugLog(@"Documents directory not found!");
		return;
	}
	
	NSFileManager* fileManager = [[NSFileManager alloc] init];
	NSError* error;
	
	NSString *thePath = [documentsDirectory stringByAppendingString:TAGLISTFILE];
	DebugLog(@"path is %@", thePath);
	[fileManager removeItemAtPath:thePath error:&error];
	thePath = [documentsDirectory stringByAppendingString:SUBSCRIPTIONLISTFILE];
	DebugLog(@"path is %@", thePath);
	[fileManager removeItemAtPath:thePath error:&error];
	thePath = [documentsDirectory stringByAppendingString:UNREADCOUNTFILE];
	DebugLog(@"path is %@", thePath);
	[fileManager removeItemAtPath:thePath error:&error];
	thePath = [documentsDirectory stringByAppendingString:FAVORITELISTFILE];
	DebugLog(@"path is %@", thePath);
	[fileManager removeItemAtPath:thePath error:&error];
	//	thePath = [documentsDirectory stringByAppendingString:CACHEFILE];
	//	[self.cache writeToFile:thePath atomically:YES];
	[fileManager release];
	DebugLog(@"removing done!!");
}

-(void)buildProcessedList{
	
	NSMutableDictionary* tempTagList = [[NSMutableDictionary alloc] initWithCapacity:0];
	NSMutableDictionary* tempSubList = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	@synchronized(_tagDict){
		NSArray* tags = [self.tagDict objectForKey:@"tags"];
		for (NSDictionary* tag in tags){
			[tempTagList setObject:[GRTag tagWithJSONObject:tag] forKey:[tag objectForKey:@"id"]];
		}
	}
	
	@synchronized(_subDict){
		DebugLog(@"subDict count is %d", [self.subDict count]);
		NSArray* subs = [self.subDict objectForKey:@"subscriptions"];
		for (NSDictionary* sub in subs){
			GRSubscription* newSub = [GRSubscription subscriptionWithJSONObject:sub];
			
			[tempSubList setObject:newSub forKey:[sub objectForKey:@"id"]];
			
			NSArray* orgCategoies = [sub objectForKey:@"categories"];
			for (NSDictionary* category in orgCategoies){
				NSString* tagID = (NSString*)[category objectForKey:@"id"];
				[newSub.categories addObject:tagID];
				GRTag* tempTag = [tempTagList objectForKey:tagID];
				NSString* tempLabel = [category objectForKey:@"label"];
				if (tempLabel && ![tempLabel isEqualToString:@""]){
					tempTag.label = tempLabel;
				}
//				[tempTag.subscriptions addObject:newSub.ID];
			}
		}
	}

	self.processedTagDict = tempTagList;
	self.processedSubDict = tempSubList;
	[tempTagList release];
	[tempSubList release];
}

-(void)updateUnreadCountToProcessedList
{
	NSMutableDictionary* tempTagDict = self.processedTagDict;
	NSMutableDictionary* tempSubDict = self.processedSubDict;
	

	//add unread count
	NSArray* tempUnreadArray = [self.unreadCount objectForKey:@"unreadcounts"];
	NSMutableDictionary* allUnreadUnit = [NSMutableDictionary dictionaryWithCapacity:0];

	for (NSDictionary* unreadUnit in tempUnreadArray){
		[allUnreadUnit setObject:unreadUnit forKey:[unreadUnit objectForKey:@"id"]];
	}
	
	NSArray* allTag = [tempTagDict allValues];
	
	for (GRTag* tempTag in allTag){
		NSDictionary* unread = [allUnreadUnit objectForKey:tempTag.ID];
		
		if (unread){
			tempTag.unreadCount = [(NSString*)[unread objectForKey:@"count"] intValue];
			tempTag.newestItemTimestampUsec = [(NSString*)[unread objectForKey:@"newestItemTimestampUsec"] doubleValue];
		}else {
			tempTag.unreadCount = 0;
		}

	}
	
	NSArray* allSub = [tempSubDict allValues];
	
	for (GRSubscription* tempSub in allSub){
		NSDictionary* unread = [allUnreadUnit objectForKey:tempSub.ID];
		
		if (unread){
			tempSub.unreadCount = [(NSString*)[unread objectForKey:@"count"] intValue];
			tempSub.newestItemTimestampUsec = [(NSString*)[unread objectForKey:@"newestItemTimestampUsec"] doubleValue];
		}else {
			tempSub.unreadCount = 0;
		}

	}

}

-(void)subscribeFeed:(NSString*)streamID 
		   withTitle:(NSString*)title
			withTag:(NSString*)tag{
	NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithCapacity:0];
	if (streamID){
		[parameters setObject:streamID forKey:@"streamID"];
	}
	
	if (title){
		[parameters setObject:title forKey:@"title"];
	}

	if (tag){
		[parameters setObject:tag forKey:@"tag"];
	}

	NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(taskSubscribeFeed:) object:parameters];
	[self.editOperationQueue addOperation:operation];
	[operation release];
}

-(void)taskSubscribeFeed:(NSDictionary*)parameters{
	NSString* streamID = [parameters objectForKey:@"streamID"];
//	NSString* title = [parameters objectForKey:@"title"];
	NSString* tag = [parameters objectForKey:@"tag"];
	
	//need to get title first if it's nil;
	GRFeed* feed = [self.grController getFeedForID:streamID
											 count:[NSNumber numberWithInt:1] 
										 startFrom:nil 
										   exclude:nil 
									  continuation:nil];
	NSString* result = nil;
	if (feed){
		result = [self.grController addSubscription:streamID 
													withTitle:feed.title
														toTag:tag];	
	}
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:streamID, NOTIFICATION_SUBSCRIBEFEED_STREAMID, nil];
	if (!result){//failed to subscribe
		//send out notification about failed to subscribe
		[self sendNotification:NOTIFICATION_SUBSCRIBEFEED_FAILED withUserInfo:userInfo];
	}else {//success, then refresh sub and unread count
		//send out notification saying that success to subscribe
		[self sendNotification:NOTIFICATION_SUBSCRIBEFEED_SUCCESS withUserInfo:userInfo];
	}

}

-(void)successfullySubscribed:(NSNotification*)notification{
	NSString* streamID = [notification.userInfo objectForKey:NOTIFICATION_SUBSCRIBEFEED_STREAMID];
	//if successfully subscribed then refresh rec feed list and reader structure
//	if (![self.lastSubscribedStreamID isEqualToString:streamID]){
		[[GRDataManager shared] refreshRecFeedsList];
		[[GRDataManager shared] syncReaderStructure];
		self.lastSubscribedStreamID = streamID;
//	}
}

-(void)unsubscribeFeed:(NSString*)streamID{
	DebugLog(@"going to unsubscribe feed:%@", streamID);
	NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(taskUnsbuscribeFeed:) object:streamID];
	[self.editOperationQueue addOperation:operation];
	[operation release];
}

-(void)taskUnsbuscribeFeed:(NSString*)streamID{
	[self.grController removeSubscription:streamID];
	[self taskSyncReaderStructure];
}

-(void)removeTag:(NSString*)tag{
	DebugLog(@"going to remove tag:%@", tag);
	NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(taskRemoveTag:) object:tag];
	[self.editOperationQueue addOperation:operation];
	[operation release];
}

-(void)taskRemoveTag:(NSString*)tag{
	[self.grController disableTag:tag];
	[self taskSyncReaderStructure];
}

-(void)cleanPooledObjects{
	[self.cache removeAllObjects];
	[self.itemPool removeAllObjects];
	[self.feedPool removeAllObjects];
}

-(void)cleanAllData{
	[self cleanPooledObjects];
	[self removeSavedFiles];
}

-(void)clearMemory{
	[self cleanPooledObjects];
}

-(void)cleanCache{
	[self.cache removeAllObjects];
}

-(void)dealloc{
    [self unregisterNotifications];
	[self writeListToFile];
    self.tagDict = nil;
    self.subDict = nil;
    self.unreadCount = nil;
    self.cache = nil;
    self.itemPool = nil;
    self.feedPool = nil;
    self.grController = nil;
    self.feedOperationQueue = nil;
    self.editOperationQueue = nil;
    self.processedSubDict = nil;
    self.processedTagDict = nil;
    self.runningOperationKeys = nil;
    self.recFeedList = nil;
	self.lastSubscribedStreamID = nil;
	[super dealloc];
}

+ (GRDataManager*)shared
{
    if (readerDM == nil) {
        readerDM = [[super allocWithZone:NULL] init];
    }
    return readerDM;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self shared] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

@end
