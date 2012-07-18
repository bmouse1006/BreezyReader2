//
//  GRSubDownloader.h
//  BreezyReader
//
//  Created by Jin Jin on 10-7-25.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRObjectsManager.h"
#import "GRSubscription.h"
#import "GRItemDownloader.h"
#import "GoogleReaderController.h"

typedef enum {
	GRDownloaderStatesStopped = 0,
	GRDownloaderStatesRunning,
	GRDownloaderStatesWaitting,
	GRDownloaderStatesAll
} GRDownloaderStates;


@protocol GRSubDownloaderDelegate

//right before downloading started
-(BOOL)willStartDownloadingSubscription:(GRSubscription*)sub;
//downloading is started
-(void)didStartDownloadingSubscription:(GRSubscription*)sub;
//downloading will finish
-(void)willFinishDownloadingSubscription:(GRSubscription*)sub;
//downloading finished
-(void)didFinishDownloadingSubscription:(GRSubscription*)sub success:(NSUInteger)success failed:(NSUInteger)failed;
//downloading was stopped by some reason (not finished yet)
-(void)didStopDownloadingSubscription:(GRSubscription*)sub;
//downloading failed
-(void)didFailDownloadingSubscription:(GRSubscription*)sub error:(NSError*)error;
//tell delegate that total number of items to be downloaded
-(void)numberOfItemsToBeDownloaded:(GRSubscription*)sub number:(NSUInteger)number;
//tell delegate that number of downloaded items
-(void)numberOfItemsThatFinishedDownloading:(GRSubscription*)sub number:(NSUInteger)number;
//number of item failed downloading
-(void)numberOfItemsThatFailedDownloading:(GRSubscription*)sub number:(NSUInteger)number;

-(void)downloaderStatesChangedForSub:(GRSubscription*)sub from:(GRDownloaderStates)from to:(GRDownloaderStates)to;

@end

@interface GRSubDownloader : NSObject<GRItemDownloaderDelegate, GoogleReaderControllerDelegate>

@property (nonatomic, strong) NSObject<GRSubDownloaderDelegate>* delegate;
@property (nonatomic, assign, readonly) GRDownloaderStates states;
@property (nonatomic, strong) NSURLConnection* connection;
@property (nonatomic, strong) GRSubscription* subscription;
@property  NSMutableDictionary* currentDownloaderPool;
@property (nonatomic, assign) NSUInteger numberOfDownloadedItems;
@property (nonatomic, assign) NSUInteger numberOfTotalItems;
@property (nonatomic, assign) NSUInteger numberOfSuccessDownload;
@property (nonatomic, assign) NSUInteger numberOfFailedDownload;
@property (nonatomic, assign) BOOL itemLoadingDone;
@property (nonatomic, assign) BOOL subscriptionLoadingFailed;
@property (nonatomic, strong) NSOperationQueue* operationQueue;
@property (nonatomic, strong) NSError* downloadError;
@property (nonatomic, strong) NSThread* thread;
@property (nonatomic, strong) NSManagedObjectContext* context;

-(id)initWithSubscription:(GRSubscription*)sub delegate:(NSObject<GRSubDownloaderDelegate>*)mDelegate;
-(BOOL)stop;
-(BOOL)start;
-(BOOL)pause;
-(BOOL)resume;

-(NSUInteger)numberOfItemsToBeDownloaded:(GRSubscription*)sub;
-(void)finishedLoadingItems;

-(void)didReceiveErrorWhileRequestingData:(NSError*)error;
-(void)didSuccessFinishedDataReceive:(NSURLResponse*)response;

-(void)initNumbersAndStates;

@end

@interface GRSubDownloader (private)

-(void)setDownloaderStates:(GRDownloaderStates)state;

@end



