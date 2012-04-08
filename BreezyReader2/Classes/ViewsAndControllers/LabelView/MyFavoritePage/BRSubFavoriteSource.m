//
//  BRSubFavoriteSource.m
//  BreezyReader2
//
//  Created by Jin Jin on 12-4-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRSubFavoriteSource.h"
#import "BRReadingStatistics.h"
#import "GRSubscription.h"
#import "GRDataManager.h"

#define kFavoriteSubCount 10

@implementation BRSubFavoriteSource

-(NSString*)title{
    return NSLocalizedString(@"title_favorite", nil);
}

-(void)loadSourceMore:(BOOL)more{
    BRReadingStatistics* statistics = [BRReadingStatistics statistics];
    NSArray* subKeys = [statistics mostReadSubscriptionIDsCount:kFavoriteSubCount];
    NSMutableArray* subs = [NSMutableArray array];
    for (NSString* key in subKeys){
        id sub = [[GRDataManager shared] getUpdatedGRSub:key];
        if (sub){
            [subs addObject:sub];
        }
    }
    self.subscriptions = subs;
    [self.delegate sourceLoadFinished];
}


@end
