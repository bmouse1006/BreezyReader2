//
//  GRDataManager.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleAppLib.h"
#import "GRTag.h"
#import "GRItem.h"
#import "GRFeed.h"
#import "GRSubscription.h"

#define CONTINUEDFEEDKEY		@"continuedFeed"

#define TAGLISTFILE				@"ReaderDataManagerTagList.plist"
#define	SUBSCRIPTIONLISTFILE	@"ReaderDataManagerSubScriptionList.plist"
#define UNREADCOUNTFILE			@"ReaderDataManagerUnreadCount.plist"
#define CACHEFILE				@"ReaderDataManagerCache.plist"
#define FAVORITELISTFILE		@"ReaderDataManagerFavorite.plist"

#define DEFAULTITEMCOUNT		10

@interface GRDataManager : NSObject<GoogleReaderControllerDelegate> 

@property (strong)  NSDictionary* tagDict;
@property (strong)  NSDictionary* subDict;
@property (strong)  NSDictionary* unreadCount;
@property (strong)  NSMutableDictionary* processedTagDict;
@property (strong)  NSMutableDictionary* processedSubDict;
@property (strong)  NSMutableDictionary* favoriteSubDict;

@property (strong)  NSMutableDictionary* cache;
@property (strong)  NSMutableDictionary* feedPool;
@property (strong)  NSMutableDictionary* itemPool;
@property (strong)  GoogleReaderController* grController;
@property (strong)  NSOperationQueue* feedOperationQueue;
@property (strong)  NSOperationQueue* editOperationQueue;
@property (strong)  NSArray* recFeedList;

@property (strong)  NSMutableSet* runningOperationKeys;

@property (strong)  NSError* grError;
@property (assign) BOOL errorHappened;

@property (nonatomic, strong) NSString* lastSubscribedStreamID;

+ (GRDataManager*)shared;
+(void)didReceiveMemoryWarning;

-(GRTag*)getUpdatedGRTag:(NSString*)tagID;
-(GRSubscription*)getUpdatedGRSub:(NSString*)subID;

-(NSArray*)getSubscriptionListWithTag:(NSString*)tagID;//get subscription list for a tag
-(NSArray*)getAllSubscriptions;
-(NSArray*)getTagListContainsText:(NSString*)str;//get a tag list that contains specific text (for label and state)
-(NSArray*)getLabelList;
-(NSArray*)getStateList;
-(NSArray*)getFavoriteSubList;//get my favorite subscription list (currently returns nil)
-(NSArray*)getRecFeedList;//get recommended feed list
-(NSDictionary*)getUnreadCount;//get return count for all sub and tag

-(void)syncUnreadCount;
-(void)syncUnreadCount_new;
-(void)syncReaderStructure;
-(void)syncReaderStructure_new;

-(GRFeed*)feedWithSubID:(NSString*)subID;//get a Feed for specific subscription ID
-(GRItem*)itemWithID:(NSString*)itemID;//get a Item for specific item ID
-(void)refreshFeedWithSub:(GRSubscription*)sub manually:(BOOL)manually;
-(void)continuingFeed:(GRFeed*)feed;

-(void)markItemsAsRead:(NSArray*)items;
-(void)markItemAsRead:(GRItem*)item;
-(void)markAllAsRead:(GRSubscription*)sub waitUtilDone:(BOOL)wait;
-(void)refreshRecFeedsList;
-(void)reloadData;
-(void)reloadData_new;

-(void)subscribeFeed:(NSString*)streamID withTitle:(NSString*)title withTag:(NSString*)tag;
-(void)unsubscribeFeed:(NSString*)streamID;
-(void)removeTag:(NSString*)tag;

-(void)didReceiveErrorWhileRequestingData:(NSError *)error;
-(void)didSuccessFinishedDataReceive:(NSURLResponse*)response;

-(void)cleanPooledObjects;
-(void)cleanAllData;

@end

@interface GRDataManager (private) 

-(NSArray*)getSubscriptionListWithoutTag;//get subscription list that with no tag

-(void)readerDMSetup;
-(void)sendNotification:(NSString*)name withUserInfo:(NSDictionary*)userInfo;
-(void)notifyErrorHappened;
-(void)readNewDataUnsynchronizly;
-(void)readListFromFile;
-(void)writeListToFile;
-(void)removeSavedFiles;

-(void)taskSyncReaderStructure;
-(void)taskContinuingFeed:(GRFeed*)feed;
-(void)taskSyncSubscriptions;
-(void)taskSyncTags;
-(void)taskSyncUnreadCount;
-(void)taskMarkAllAsRead:(GRSubscription*)sub;

-(void)buildProcessedList;
-(void)updateUnreadCountToProcessedList;
-(void)cleanCache;
-(void)clearMemory;

@end