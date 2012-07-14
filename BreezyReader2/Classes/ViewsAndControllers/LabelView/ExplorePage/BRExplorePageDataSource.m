//
//  BRExplorePageDataSource.m
//  BreezyReader2
//
//  Created by 津 金 on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRExplorePageDataSource.h"
#import "GRSubscription.h"

@implementation BRExplorePageDataSource

-(NSString*)title{
    return NSLocalizedString(@"title_explore", nil);
}

-(void)loadSourceMore:(BOOL)more{
    //unread article
    GRSubscription* allItems = [GRSubscription subscriptionForAllItems];
    GRSubscription* allUnread = [GRSubscription subscriptionForUnread];
    self.subscriptions = [NSArray arrayWithObjects:allItems, allUnread, nil];
//    /user/09810084055967723312/state/com.google/fresh    
    //all article
//    /user/09810084055967723312/state/com.google/reading-list
    [self.delegate sourceLoadFinished];
}

@end
