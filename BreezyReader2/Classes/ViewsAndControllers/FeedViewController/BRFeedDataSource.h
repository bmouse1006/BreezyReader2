//
//  BRFeedDataSource.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRBaseDataSource.h"
#import "GRSubscription.h"
#import "GRFeed.h"
#import "GoogleReaderClient.h"

@interface BRFeedDataSource : BRBaseDataSource

@property (nonatomic, retain) NSMutableArray* items;
@property (nonatomic, retain) GRSubscription* subscription;
@property (nonatomic, retain) GRFeed* feed;
@property (nonatomic, retain) GRFeed* moreFeed;

@property (nonatomic, retain) GoogleReaderClient* client;

@end
