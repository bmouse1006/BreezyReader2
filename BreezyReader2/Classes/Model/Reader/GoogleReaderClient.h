//
//  GoogleReaderClient.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRItem.h"
#import "GRFeed.h"
#import "GRTag.h"
#import "GRSubscription.h"
#import "ASIHTTPRequest.h"

typedef enum{
    BRTagTypeLabel,
    BRTagTypeState
} BRTagType;

typedef void(^GoogleReaderCompletionHandler)(NSError*);

@interface GoogleReaderClient : NSObject<ASIHTTPRequestDelegate>

@property (weak, nonatomic, readonly) NSError* error;
@property (weak, nonatomic, readonly) NSString* responseString;
@property (weak, nonatomic, readonly) NSData* responseData;
@property (nonatomic, readonly) BOOL isResponseOK;
@property (unsafe_unretained, nonatomic, readonly) id responseJSONValue;
@property (unsafe_unretained, nonatomic, readonly) id responseFeedSearchingJSONValue;
@property (weak, nonatomic, readonly) GRFeed* responseFeed;
@property (nonatomic, readonly) BOOL didUseCachedData;

+(id)clientWithDelegate:(id)delegate action:(SEL)action;

-(id)initWithDelegate:(id)delegate action:(SEL)action;
-(void)setCompletionHandler:(GoogleReaderCompletionHandler)block;

+(BOOL)needRefreshUnreadCount;
+(BOOL)needRefreshReaderStructure;

-(void)clearAndCancel;

-(void)requestFeedWithIdentifier:(NSString*)identifer
                           count:(NSNumber*)count 
                       startFrom:(NSDate*)date 
                         exclude:(NSString*)excludeString 
                    continuation:(NSString*)continuationStr
                    forceRefresh:(BOOL)refresh 
                        needAuth:(BOOL)needAuth;

-(void)requestFeedWithIdentifier:(NSString*)identifer
                           count:(NSNumber*)count 
                       startFrom:(NSDate*)date 
                         exclude:(NSString*)excludeString 
                    continuation:(NSString*)continuationStr
                    forceRefresh:(BOOL)refresh 
                        needAuth:(BOOL)needAuth priority:(NSOperationQueuePriority)priority;
//reader structure
+(GRTag*)tagWithID:(NSString*)tagID;
+(GRSubscription*)subscriptionWithID:(NSString*)subID;
+(BOOL)containsSubscription:(NSString*)subID;
+(NSArray*)subscriptionsWithTagID:(NSString*)tagID;
+(NSArray*)tagListWithType:(BRTagType)type;
+(NSInteger)unreadCountWithID:(NSString*)ID;
+(BOOL)isReaderLoaded;
//list api
-(void)getStreamDetails:(NSString*)streamID;
-(void)queryContentsWithIDs:(NSArray*)IDArray;
-(void)searchArticlesWithKeywords:(NSString*)keywords;
-(void)searchFeedsWithKeywords:(NSString*)keywords;
-(void)requestRecommendationList;
-(void)requestRelatedSubscriptions:(NSString*)streamID;
//edit api
-(void)starArticle:(NSString*)itemID;
-(void)unstartArticle:(NSString*)itemID;
-(void)markArticleAsRead:(NSString*)itemID;
-(void)markArticleAsUnread:(NSString*)itemID;
-(void)keepArticleUnread:(NSString*)itemID;
-(void)markAllAsRead:(NSString*)streamID;
-(void)viewRecommendationStream:(NSString*)streamID;
-(void)dismissRecommendationStream:(NSString*)streamID;
-(void)addSubscription:(NSString*)subscription 
             withTitle:(NSString*)title 
                 toTag:(NSString*)tag;
-(void)removeSubscription:(NSString*)subscription;
-(void)renameSubscription:(NSString*)subscription withNewName:(NSString*)newName;
-(void)editSubscription:(NSString*)subscription 
               tagToAdd:(NSString*)tagToAdd
            tagToRemove:(NSString*)tagToRemove;
//token
+(void)setToken:(NSString*)token;
+(NSString*)token;
//sub, tag and unread count
-(void)refreshReaderStructure;
-(void)refreshUnreadCount;
-(void)refreshSubscriptionList;
//labels
+(NSString*)readArticleTag;
+(NSString*)starTag;

-(BOOL)isLoading;

+(void)removeStoredReaderData;

@end
