//
//  GRDownloadManager.h
//  BreezyReader
//
//  Created by Jin Jin on 10-7-25.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRItem.h"
#import "GRSubscription.h"
#import "GRSubDownloader.h"
#import "GRItemDownloader.h"
#import "GRSubModel.h"

#define DOWNLOADERQUEUECHANGED @"downloaderQueueChanged"
#define DOWNLOADERQUEUECHANGEDINDEXSET @"indexSet"
#define DOWNLOADERQUEUECHANGEDTYPE @"changeType"
#define DOWNLOADERQUEUECHANGEDMOVEFROM @"moveFrom"
#define DOWNLOADERQUEUECHANGEDMOVETO @"moveTo"

typedef enum{
	GRDownloaderQueueChangeTypeInsert,
	GRDownloaderQueueChangeTypeRemove,
	GRDownloaderQueueChangeTypeUpdate,
	GRDownloaderQueueChangeTypeMove,
	GRDownloaderQueueChangeTypeStateChange
} GRDownloadManagerQueueChangeType;

@interface GRDownloadManager : NSObject<GRSubDownloaderDelegate, GRItemDownloaderDelegate>

@property  NSMutableArray* downloaderQueue;
@property  NSMutableDictionary* downloaderIndex;
@property (nonatomic, assign) NSUInteger maxConcurrency;
@property (assign, readonly) NSUInteger numberOfRunningDownloader;
@property (nonatomic, strong) NSMutableDictionary* itemDownloaderDictionary;
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext* context;

-(BOOL)containsDownloaderForSub:(GRSubscription*)sub;
-(BOOL)addSubscriptionToDownloadQueue:(GRSubscription*)sub;
-(BOOL)removeDownloaderForSub:(GRSubscription *)sub;
-(BOOL)removeDownloader:(GRSubDownloader*)downloader;
-(BOOL)setDownloadStatusForSubscription:(GRSubscription *)sub;
-(BOOL)saveSingleItem:(GRItem*)item;
-(BOOL)stopAllDownloaders;
-(BOOL)startAllDownloaders;
-(BOOL)stopDownloaderForSub:(GRSubscription*)sub;
-(BOOL)startDownloaderForSub:(GRSubscription*)sub;
-(NSUInteger)numberofDownloadersForStates:(GRDownloaderStates)states;
+ (GRDownloadManager*)shared;
-(GRSubDownloader*)downloaderForSub:(GRSubscription*)sub;
+(void)didReceiveMemoryWarning;
-(BOOL)itemDownloaded:(GRItem*)item;
-(GRSubModel*)downloadedSubscriptionForID:(NSString*)subID;

@end

