//
//  GRSubDownloader.m
//  BreezyReader
//
//  Created by Jin Jin on 10-7-25.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GRSubDownloader.h"
#import "GRDataManager.h"
#import "GRObjectsManager.h"
#import "GRDownloadManager.h"
#import "GRSubModel.h"
#import "GoogleReaderController.h"
#import "UserPreferenceDefine.h"

@implementation GRSubDownloader

@synthesize delegate = _delegate;
@synthesize connection = _connection;
@synthesize subscription = _subscription;
@synthesize currentDownloaderPool = _currentDownloaderPool;
@synthesize numberOfDownloadedItems = _numberOfDownloadedItems;
@synthesize numberOfTotalItems = _numberOfTotalItems;
@synthesize numberOfSuccessDownload = _numberOfSuccessDownload;
@synthesize numberOfFailedDownload = _numberOfFailedDownload;
@synthesize states = _states;
@synthesize itemLoadingDone = _itemLoadingDone;
@synthesize operationQueue = _operationQueue;
@synthesize subscriptionLoadingFailed = _subscriptionLoadingFailed;
@synthesize downloadError = _downloadError;
@synthesize thread = _thread;
@synthesize context = _context;

#pragma mark actions

-(void)finishedLoadingItems{
	
	if ([self.thread isCancelled]){
		[self.delegate didStopDownloadingSubscription:self.subscription];
		return;
	}
	
	if (self.subscriptionLoadingFailed){
		[self stop];//stop all started downloader when error happens
		[self.delegate didFailDownloadingSubscription:self.subscription 
												  error:self.downloadError];
	}else{
		@synchronized(_currentDownloaderPool){
			if (![self.currentDownloaderPool count]){
				[self setDownloaderStates:GRDownloaderStatesStopped];
				self.numberOfSuccessDownload = self.numberOfTotalItems - self.numberOfFailedDownload;
				[GRObjectsManager commitChangeForContext:self.context];
				[self.delegate didFinishDownloadingSubscription:self.subscription
														success:self.numberOfSuccessDownload 
														 failed:self.numberOfFailedDownload];
			}
		}
	}
}

-(BOOL)start{

	if (self.states != GRDownloaderStatesRunning){
		if (![self.delegate willStartDownloadingSubscription:self.subscription]){
			[self setDownloaderStates:GRDownloaderStatesWaitting];
			return NO;
		}
		
		[self initNumbersAndStates];
		[self setDownloaderStates:GRDownloaderStatesRunning];

		self.thread = nil;
		
		NSThread* mThread = [[NSThread alloc] initWithTarget:self 
													selector:@selector(mainDownloadTask)
													  object:nil];
		self.thread = mThread;
		[mThread release];

		[self.thread start];
		
		[self.delegate didStartDownloadingSubscription:self.subscription];
	}
	
	return YES;
}

-(BOOL)stop{
	if (self.states == GRDownloaderStatesStopped){
		return YES;
	}
	[self.thread cancel];
	//stop all item downloader and empty downloader pool 
	NSDictionary* dictionary = [[NSDictionary alloc] initWithDictionary:self.currentDownloaderPool copyItems:NO];	
	
	NSEnumerator* enumerator = [dictionary objectEnumerator];
	
	GRItemDownloader* downloader = nil;
	
	while (downloader = [enumerator nextObject]){
		[downloader cancel];
	}
	
	[dictionary release];
	[self setDownloaderStates:GRDownloaderStatesStopped];
	self.numberOfSuccessDownload = 0;
	@synchronized(_currentDownloaderPool){
		[self.currentDownloaderPool removeAllObjects];
	}
	
	//commit all change before stop
	[GRObjectsManager commitChangeForContext:self.context];
	GRSubModel* sub = [[GRDownloadManager shared] downloadedSubscriptionForID:self.subscription.ID];
	[GRObjectsManager commitChangeForContext:[sub managedObjectContext]];
	
	[self.delegate didStopDownloadingSubscription:self.subscription];
	
	return YES;
}

-(BOOL)pause{
	return NO;
}

-(BOOL)resume{
	return NO;
}

#pragma mark -
#pragma mark main task
-(void)mainDownloadTask{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	DebugLog(@"GR Sub Downloader started");
	//did start downloading subscription
	[self.delegate didStartDownloadingSubscription:self.subscription];
	NSUInteger unreadCount = self.subscription.unread;
	NSUInteger itemCount = [UserPreferenceDefine defaultNumberOfDownloaderItems];
	
	GoogleReaderController* grController = [[GoogleReaderController alloc] initWithDelegate:self];
	GRFeed* feed = nil;
	NSString* continuation = nil;
	NSString* excludeLabel = [ATOM_PREFIX_STATE_GOOGLE stringByAppendingString:ATOM_STATE_READ];
	
	NSUInteger count = 0;
	
	do{
		
		feed = [grController getFeedForID:self.subscription.ID
									count:[NSNumber numberWithInt:itemCount]
								startFrom:nil 
								  exclude:excludeLabel
							 continuation:continuation];//read online
		if (self.subscriptionLoadingFailed){
			break;
		}
		
		continuation = feed.gr_continuation;
		
		if ([self.thread isCancelled]){
			break;
		}
		
		[feed retain];
		
		for (GRItem* item in feed.items){
			@synchronized(_currentDownloaderPool){
				GRItemDownloader* downloader = [[GRItemDownloader alloc] initWithGRItem:item
																			   delegate:self
																			   startNow:NO 
																				context:self.context];
				DebugLog(@"downloader address is %d", downloader);
				[self.currentDownloaderPool setObject:downloader 
											   forKey:item.ID];
				[downloader start];
				
				[downloader release];
			}
			count++;
			
			if ([self.thread isCancelled]){
				break;
			}
		}
		
		[feed release];
		
		DebugLog(@"continuation is %@", continuation);
		DebugLog(@"count is %i", count);
		if ([self.thread isCancelled]){
			break;
		}
		
	}while (continuation && count < unreadCount);
	
	DebugLog(@"all downloaders are started");
	
	[grController release];
	
	self.itemLoadingDone = YES;
	
	[self finishedLoadingItems];
	
	[pool release];
}

-(NSUInteger)numberOfItemsToBeDownloaded:(GRSubscription*)sub{
	return [self.subscription unreadCount];
}

#pragma mark delegate method

-(void)finishedDownloadingGRItem:(GRItem*)item{
	[item retain];
	@synchronized(_currentDownloaderPool){
		DebugLog(@"finished loading item for id %@", item.ID);
		//update downloaded time;
		GRSubModel* sub = [[GRDownloadManager shared] downloadedSubscriptionForID:item.origin_streamId];
		sub.downloadedDate = [NSDate date];
		//we need get subscription (not tag) for this item and set latest downloaded time
		//save item
		//set this item as read
		if ([UserPreferenceDefine markDownloadedItemsAsRead]){
			[[GRDataManager shared] markItemAsRead:item];
		}
		self.numberOfSuccessDownload = self.numberOfSuccessDownload + 1;
		DebugLog(@"number of success downloaded is %i", self.numberOfSuccessDownload);
		//tell delegate that 'number' items has been downloaded
		[self.delegate numberOfItemsThatFinishedDownloading:self.subscription 
													 number:self.numberOfDownloadedItems];
		//remove downloader from pool
		[self.currentDownloaderPool removeObjectForKey:item.ID];//here, it's been freed.....
		//if downloader pool empty and item loading done, means download finished
		if (![self.currentDownloaderPool count] && self.itemLoadingDone){
			[self finishedLoadingItems];
		}
	}
	[item release];
}

-(void)failedDownloadingGRItem:(GRItem*)item{
	self.numberOfFailedDownload = self.numberOfFailedDownload + 1;
	[self.delegate numberOfItemsThatFailedDownloading:self.subscription 
											   number:self.numberOfFailedDownload];
	//what if there is an item failed downloading?
}

#pragma mark -
#pragma mark delegate for GoogleReaderController
-(void)didReceiveErrorWhileRequestingData:(NSError*)error{
	DebugLog(@"Downloading subscription failed: %@", self.subscription.ID);
	self.subscriptionLoadingFailed = YES;
	self.downloadError = error;
}

-(void)didSuccessFinishedDataReceive:(NSURLResponse*)response{

}

#pragma mark -
#pragma mark init and alloc
-(id)initWithSubscription:(GRSubscription*)sub delegate:(NSObject<GRSubDownloaderDelegate>*)mDelegate{

	if (self = [super init]){
		self.delegate = mDelegate;
		self.subscription = sub;
		self.operationQueue = nil;
		[self initNumbersAndStates];
	}
	return self;
}

-(void)initNumbersAndStates{
	self.currentDownloaderPool = [NSMutableDictionary dictionary];
	self.numberOfDownloadedItems = 0;
	self.numberOfTotalItems = self.subscription.unread;
	self.numberOfSuccessDownload = 0;
	self.numberOfFailedDownload = 0;
	self.itemLoadingDone = NO;
	self.subscriptionLoadingFailed = NO;
	self.context = [GRObjectsManager context];
	[self setDownloaderStates:GRDownloaderStatesWaitting];
	
}

-(void)dealloc{
    self.delegate = nil;
    self.connection = nil;
    self.subscription = nil;
    self.currentDownloaderPool = nil;
    self.operationQueue = nil;
    self.downloadError = nil;
    self.thread = nil;
    self.context = nil;
	[super dealloc];
}

@end

@implementation GRSubDownloader (private)

-(void)setDownloaderStates:(GRDownloaderStates)newStates{
	GRDownloaderStates preStates = _states;
	_states = newStates;
	[self setValue:[NSNumber numberWithInt:newStates] forKey:@"states"];
	[self.delegate downloaderStatesChangedForSub:self.subscription
											from:preStates
											  to:newStates];
	
}

@end