//
//  GRSubscription.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRBaseProtocol.h"
#import "GRRecFeed.h"

@interface GRSubscription : NSObject<GRBaseProtocol>

@property (nonatomic, retain) NSString* ID;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* sortID;
@property (nonatomic, retain) NSMutableSet* categories;
@property (nonatomic, retain) NSDate* downloadedDate;

@property (nonatomic, assign) NSInteger unread;
@property (nonatomic, assign) NSTimeInterval newestItemTimestampUsec;
@property (nonatomic, assign) NSTimeInterval firstItemMSec;
@property (nonatomic, assign) BOOL isUnreadOnly;

@property (nonatomic, readonly) NSDate* firstItemDate;
@property (nonatomic, readonly) NSDate* newestItemDate;

-(NSString*)presentationString;
-(NSInteger)unreadCount;
-(UIImage*)icon;
-(NSString*)keyString;

-(GRRecFeed*)recFeedFromSubscription;

+(GRSubscription*)subscriptionWithJSONObject:(NSDictionary*)JSONSub;

+(GRSubscription*)subscriptionForAllItems;

+(GRSubscription*)subscriptionForGRRecFeed:(GRRecFeed*)recFeed;

@end
