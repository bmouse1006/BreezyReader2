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

@interface GoogleReaderClient : NSObject<ASIHTTPRequestDelegate>

@property (nonatomic, readonly) NSError* error;
@property (nonatomic, readonly) NSString* responseString;
@property (nonatomic, readonly) NSData* responseData;
@property (nonatomic, readonly) BOOL isResponseOK;
@property (nonatomic, readonly) id responseJSONValue;
@property (nonatomic, readonly) id responseFeedSearchingJSONValue;
@property (nonatomic, readonly) GRFeed* responseFeed;

+(id)clientWithDelegate:(id)delegate action:(SEL)action;

-(id)initWithDelegate:(id)delegate action:(SEL)action;

-(BOOL)needRefreshUnreadCount;

-(void)clearAndCancel;

-(void)requestFeedWithIdentifier:(NSString*)identifer
                           count:(NSNumber*)count 
                       startFrom:(NSDate*)date 
                         exclude:(NSString*)excludeString 
                    continuation:(NSString*)continuationStr
                    forceRefresh:(BOOL)refresh 
                        needAuth:(BOOL)needAuth;
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
                 toTag:(NSString*)tags;
-(void)removeSubscription:(NSString*)subscription;
-(void)renameSubscription:(NSString*)subscription withNewName:(NSString*)newName;
-(void)editSubscription:(NSString*)subscription 
               tagsToAdd:(NSArray*)tagsToAdd
            tagsToRemove:(NSArray*)tagsToRemove;
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

@end
