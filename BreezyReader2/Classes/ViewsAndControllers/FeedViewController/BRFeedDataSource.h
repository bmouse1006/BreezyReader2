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

@property (nonatomic, strong) GRSubscription* subscription;
@property (nonatomic, strong) GRFeed* feed;
@property (nonatomic, strong) GRFeed* moreFeed;
@property (nonatomic, copy) NSString* exclude;
@property (nonatomic, assign) BOOL unreadOnly;

@property (nonatomic, strong) GoogleReaderClient* client;

@end
