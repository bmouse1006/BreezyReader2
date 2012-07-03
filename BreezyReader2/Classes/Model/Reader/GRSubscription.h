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

@class GRTag;

@interface GRSubscription : NSObject<GRBaseProtocol, NSCoding>

@property (nonatomic, retain) NSString* ID;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* sortID;
@property (nonatomic, retain) NSMutableSet* categories;
@property (nonatomic, retain) NSDate* downloadedDate;

@property (nonatomic, assign) NSInteger unreadCount;
@property (nonatomic, assign) NSTimeInterval newestItemTimestampUsec;
@property (nonatomic, assign) NSTimeInterval firstItemMSec;
@property (nonatomic, assign) BOOL isUnreadOnly;

@property (nonatomic, readonly) NSDate* firstItemDate;
@property (nonatomic, readonly) NSDate* newestItemDate;

-(NSString*)presentationString;
-(UIImage*)icon;
-(NSString*)keyString;
-(NSArray*)keysForLabels;

-(GRRecFeed*)recFeedFromSubscription;

+(GRSubscription*)subscriptionWithJSONObject:(NSDictionary*)JSONSub;

+(GRSubscription*)subscriptionForAllItems;
+(GRSubscription*)subscriptionForLabel:(NSString*)label;
+(GRSubscription*)subscriptionForGRRecFeed:(GRRecFeed*)recFeed;

-(BOOL)isStream;

@end
