//
//  GRDownloadManager.m
//  BreezyReader
//
//  Created by Jin Jin on 10-7-25.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GRDownloadManager.h"
#import "GRSubDownloader.h"
#import "UserPreferenceDefine.h"
#import "GRDataManager.h"
#import "GRObjectsManager.h"
#import "GRSubModel.h"

@interface GRDownloadManager (private)

-(void)downloaderQueueChanged;
-(void)startTopWaittingDownloader;
-(void)sendDownloaderQueueChangedNotification:(NSIndexSet*)indexSet 
							  queueChangeType:(GRDownloadManagerQueueChangeType)changeType;
-(NSArray*)fetchDownloadedSub;
-(NSMutableDictionary*)cachedDownloadedSubscriptions;
-(void)setupFetchedController;

@end

@implementation GRDownloadManager

@synthesize downloaderQueue = _downloaderQueue;
@synthesize downloaderIndex = _downloaderIndex;

@synthesize maxConcurrency = _maxConcurrency;
@synthesize numberOfRunningDownloader = _numberOfRunningDownloader;
@synthesize itemDownloaderDictionary = _itemDownloaderDictionary;

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize context = _context;

static NSMutableDictionary* _cachedDownloadedSub = nil;

-(BOOL)containsDownloaderForSub:(GRSubscription*)sub{
	BOOL result = NO;
	if ([self.downloaderIndex objectForKey:sub.ID]){
		result = YES;
	}
	return result;
}

//number of downloaders for specific states

-(NSUInteger)numberofDownloadersForStates:(GRDownloaderStates)states{
	if (states == GRDownloaderStatesAll){
		return [self.downloaderQueue count];
	}
	
	NSUInteger count = 0;
	@synchronized(_downloaderQueue){
		for (GRSubDownloader* downloader in self.downloaderQueue){
			if (downloader.states == states)
				count++;
		}
	}
	
	return count;
}

-(GRSubDownloader*)downloaderForSub:(GRSubscription*)sub{
	GRSubDownloader* downloader = [self.downloaderIndex objectForKey:sub.ID];
	return downloader;
}

//add a subscription to the download queue
-(BOOL)addSubscriptionToDownloadQueue:(GRSubscription *)sub{
	if ([self.downloaderIndex objectForKey:sub.ID]){
		return NO;//don't add duplicate subscription
	}else {
		GRSubDownloader* downloader = [[GRSubDownloader alloc] initWithSubscription:sub
																	 delegate:self];
		@synchronized(_downloaderQueue){
			[self.downloaderQueue addObject:downloader];
			[self.downloaderIndex setObject:downloader forKey:sub.ID];
			
			[self sendDownloaderQueueChangedNotification:[NSIndexSet indexSetWithIndex:[self.downloaderQueue count]-1] 
										 queueChangeType:GRDownloaderQueueChangeTypeInsert];
		}
		[downloader release];
		DebugLog(@"new downloader added");
		
		[self downloaderQueueChanged];

	}
	return YES;
}

-(BOOL)removeDownloaderForSub:(GRSubscription*)sub{
	@synchronized(_downloaderQueue){
		GRSubDownloader* downloader = [self.downloaderIndex objectForKey:sub.ID];
		[downloader stop];
		if (downloader){
			NSInteger index = [self.downloaderQueue indexOfObject:downloader];
			[self.downloaderIndex removeObjectForKey:sub.ID];
			[self.downloaderQueue removeObjectAtIndex:index];
			[self sendDownloaderQueueChangedNotification:[NSIndexSet indexSetWithIndex:index] 
										 queueChangeType:GRDownloaderQueueChangeTypeRemove];
		}
	}
	return YES;
}

-(BOOL)removeDownloader:(GRSubDownloader*)downloader{
	GRSubscription* sub = downloader.subscription;
	return [self removeDownloaderForSub:sub];
}

-(BOOL)stopDownloaderForSub:(GRSubscription*)sub{
	GRSubDownloader* downloader = [self.downloaderIndex objectForKey:sub.ID];
//	[self sendDownloaderQueueChangedNotification:nil 
//								 queueChangeType:GRDownloaderQueueChangeTypeStateChange];
	return [downloader stop];
}

-(BOOL)startDownloaderForSub:(GRSubscription*)sub{
	
	GRSubDownloader* downloader = [self.downloaderIndex objectForKey:sub.ID];
	DebugLog(@"current running downloader number is %i", self.numberOfRunningDownloader);
	return [downloader start];
}

-(BOOL)stopAllDownloaders{
	@synchronized(_downloaderQueue){
		[self.downloaderQueue makeObjectsPerformSelector:@selector(stop)];
	}
//	[self sendDownloaderQueueChangedNotification:nil 
//								 queueChangeType:GRDownloaderQueueChangeTypeStateChange];
	return YES;
}
				
-(BOOL)startAllDownloaders{
	@synchronized(_downloaderQueue){
		[self.downloaderQueue makeObjectsPerformSelector:@selector(start)];
	}
	return YES;
}

-(BOOL)setDownloadStatusForSubscription:(GRSubscription*)sub{
	return YES;
}

-(BOOL)saveSingleItem:(GRItem*)item{
	if (![self.itemDownloaderDictionary objectForKey:item.ID]){
		GRItemDownloader* downloader = [[GRItemDownloader alloc] initWithGRItem:item 
																	   delegate:self
																	   startNow:NO 
																		context:self.context];
		[self.itemDownloaderDictionary setObject:downloader forKey:item.ID];
		[downloader start];
		[downloader release];
	}
	return YES;
}
								

-(void)setMaxConcurrency:(NSUInteger)concurrency{
	_maxConcurrency = concurrency;
}

-(NSUInteger)getMaxConcurrency{
	return _maxConcurrency;
}

#pragma mark setter and getter

//if number of running downloader < max concurrency then start a new waiting downloader
-(void)setNumberOfRunningDownloader:(NSUInteger)number{
	DebugLog(@"new running number is %i", number);
	@synchronized(_downloaderQueue){
		_numberOfRunningDownloader = number;
	}
}

#pragma mark delegate method for item downloader
-(void)finishedDownloadingGRItem:(GRItem*)item{
	DebugLog(@"finished downloading item: %@", item.ID);
	
	GRSubModel* sub = [self downloadedSubscriptionForID:item.origin_streamId];
	
	sub.downloadedDate = [NSDate date];
	
	[GRObjectsManager commitChangeForContext:self.context];
	
	@synchronized(_itemDownloaderDictionary){
		[self.itemDownloaderDictionary removeObjectForKey:item.ID];
	}
	
	NSDictionary* userInfo = [NSDictionary dictionaryWithObject:item forKey:@"item"];
	[[NSNotificationCenter defaultCenter] postNotificationName:ITEMDOWNLOADFINISHED 
														object:self 
													  userInfo:userInfo];
}

-(void)failedDownloadingGRItem:(GRItem*)item{
}

#pragma mark delegate method for sub downloader

//right before downloading started
-(BOOL)willStartDownloadingSubscription:(GRSubscription*)sub{
	if (self.numberOfRunningDownloader < self.maxConcurrency){
		return YES;
	}
	return NO;
}
//downloading is started
-(void)didStartDownloadingSubscription:(GRSubscription*)sub{
}
//downloading will finish
-(void)willFinishDownloadingSubscription:(GRSubscription*)sub{
}
//downloading finished
-(void)didFinishDownloadingSubscription:(GRSubscription*)sub success:(NSUInteger)success failed:(NSUInteger)failed{
	DebugLog(@"Did finished downloading subscription for ID: %@", sub.ID);
	[GRObjectsManager commitChangeForContext:self.context];
	if ([UserPreferenceDefine markDownloadedItemsAsRead]){
		[[GRDataManager shared] syncUnreadCount];
	}
	[self removeDownloaderForSub:sub];
}
-(void)didStopDownloadingSubscription:(GRSubscription*)sub{
}

//downloading failed
-(void)didFailDownloadingSubscription:(GRSubscription*)sub error:(NSError*)error{
	DebugLog(@"Did failed downloading subscription for ID: %@", sub.ID);
}
//tell delegate that total number of items to be downloaded
-(void)numberOfItemsToBeDownloaded:(GRSubscription*)sub number:(NSUInteger)number{
}
//tell delegate that number of downloaded items
-(void)numberOfItemsThatFinishedDownloading:(GRSubscription*)sub number:(NSUInteger)number{
}
//number of items that failed downloading for subscriptions
-(void)numberOfItemsThatFailedDownloading:(GRSubscription*)sub number:(NSUInteger)number{

}

-(void)downloaderStatesChangedForSub:(GRSubscription*)sub
								from:(GRDownloaderStates)from 
								  to:(GRDownloaderStates)to{
	@synchronized(self){
		if (from != to){
			if (from == GRDownloaderStatesRunning){
				self.numberOfRunningDownloader = self.numberOfRunningDownloader - 1;
				[self startTopWaittingDownloader];
			}
			
			switch (to) {
				case GRDownloaderStatesRunning:
					self.numberOfRunningDownloader = self.numberOfRunningDownloader + 1;
					break;
				case GRDownloaderStatesWaitting:
					[self startTopWaittingDownloader];
					break;
				case GRDownloaderStatesStopped:
					break;
				default:
					break;
			}
		}
	}
}

-(BOOL)itemDownloaded:(GRItem*)item{
	BOOL result = NO;
	
	NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"ID", item.ID];
	
	NSSortDescriptor* sort = [[NSSortDescriptor alloc] initWithKey:@"ID" ascending:YES];
	
	NSFetchedResultsController* fetchedController = [GRObjectsManager fetchedResultsControllerFromModel:ITEMMODELNAME 
																							  predicate:predicate 
																						sortDescriptors:[NSArray arrayWithObject:sort]];
	[sort release];
	NSError* error;
	
	[fetchedController performFetch:&error];
	
	if ([[fetchedController fetchedObjects] count]){
		result = YES;
	}
	
	return result;
}

//get a sub Model from downloaded cache
//if doesn't exist, create a new and insert to DB, then return
-(GRSubModel*)downloadedSubscriptionForID:(NSString*)subID{
	NSMutableDictionary* downloadedSubs = [self cachedDownloadedSubscriptions];
	GRSubModel* subModel = [downloadedSubs objectForKey:subID];
	
	if(!subModel){//if this subscription hasn't been saved
		GRSubscription* sub = [[GRDataManager shared] getUpdatedGRSub:subID];
		GRSubModel* subModel = (GRSubModel*)[NSEntityDescription insertNewObjectForEntityForName:SUBMODELNAME 
																		  inManagedObjectContext:self.context];
		
		[subModel setGRSub:sub];
		
		[GRObjectsManager insertObject:subModel];
		
		[downloadedSubs setObject:subModel forKey:subID];
        
	}
	
	return subModel;
}

#pragma mark -
#pragma mark Class methodes

+(void)didReceiveMemoryWarning{
	[_cachedDownloadedSub removeAllObjects];
}

#pragma mark init methodes

-(id)init{
	if (self = [super init]){
		self.maxConcurrency = [UserPreferenceDefine maxDownloadConcurrency];
		self.downloaderIndex = [NSMutableDictionary dictionary];
		self.downloaderQueue = [NSMutableArray array];
		self.itemDownloaderDictionary = [NSMutableDictionary dictionary];
		[self setupFetchedController];
		_numberOfRunningDownloader = 0;
	}
	
	return self;
}

-(void)dealloc{
    self.downloaderQueue = nil;
    self.downloaderIndex = nil;
    self.itemDownloaderDictionary = nil;
    self.fetchedResultsController = nil;
    self.context = nil;
	[super dealloc];
}

//singleton method

static GRDownloadManager* downloadManager = nil;

+ (GRDownloadManager*)shared
{
    if (downloadManager == nil) {
        downloadManager = [[super allocWithZone:NULL] init];
    }
    return downloadManager;
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

@implementation GRDownloadManager (private)

-(void)downloaderQueueChanged{
	DebugLog(@"number of running downloader is %i", self.numberOfRunningDownloader);
	DebugLog(@"downloader queue count is %i", [self.downloaderQueue count]);
	[self startTopWaittingDownloader];
}

-(void)startTopWaittingDownloader{
	if (self.numberOfRunningDownloader < self.maxConcurrency){
		@synchronized(_downloaderQueue){
			for (GRSubDownloader* downloader in self.downloaderQueue){
				if (downloader.states == GRDownloaderStatesWaitting){
					[downloader start];
					DebugLog(@"new downloader started");
					break;
				}
			}
		}
	}
}

-(void)sendDownloaderQueueChangedNotification:(NSIndexSet*)indexSet 
							  queueChangeType:(GRDownloadManagerQueueChangeType)changeType{

	NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:indexSet, DOWNLOADERQUEUECHANGEDINDEXSET, [NSNumber numberWithInt:changeType], DOWNLOADERQUEUECHANGEDTYPE, nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:DOWNLOADERQUEUECHANGED object:self userInfo:parameters];
}

-(NSMutableDictionary*)cachedDownloadedSubscriptions{
	if (!_cachedDownloadedSub){
		_cachedDownloadedSub = [[NSMutableDictionary alloc] initWithCapacity:0];
		NSArray* subs = [self fetchDownloadedSub];
		for (GRSubModel* sub in subs){
			[_cachedDownloadedSub setObject:sub forKey:sub.ID];
		}
	}
	
	return _cachedDownloadedSub;
}

-(NSArray*)fetchDownloadedSub{
											  
	NSArray* allSubs = nil;
	if (self.fetchedResultsController){
		NSError* error;
		[self.fetchedResultsController performFetch:&error];
		allSubs = self.fetchedResultsController.fetchedObjects;
	}
	
	return allSubs;
}

-(void)setupFetchedController{
	if (!self.fetchedResultsController){
		NSSortDescriptor* descriptor = [[NSSortDescriptor alloc] initWithKey:@"sortID" ascending:YES];
		NSFetchedResultsController* controller = [GRObjectsManager fetchedResultsControllerFromModel:SUBMODELNAME
																						   predicate:nil
																					 sortDescriptors:[NSArray arrayWithObject:descriptor]];
		[descriptor release];
		
		self.fetchedResultsController = controller;
		self.context = [controller managedObjectContext];
	}
}
@end