//
//  BRRecommendationDataSource.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRRecommendationDataSource.h"
#import "GRRecFeed.h"
#import "GoogleReaderClient.h"

@interface BRRecommendationDataSource ()

@property (nonatomic, retain) GoogleReaderClient* client; 

@end

@implementation BRRecommendationDataSource

@synthesize client = _client;

-(void)dealloc{
    self.client = nil;
    [super dealloc];
}

-(NSString*)title{
    return NSLocalizedString(@"title_recommendation", nil);
}

-(void)loadSourceMore:(BOOL)more{
    [self.delegate sourceStartLoading];
    [self.client clearAndCancel];
    self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(recommendationReceived:)];
    [self.client requestRecommendationList];
}

-(void)recommendationReceived:(GoogleReaderClient*)client{
    if (client.error == nil){
        DebugLog(@"%@", client.responseString);
        NSArray* recs = [[client responseJSONValue] objectForKey:@"recs"];
        NSMutableArray* subs = [NSMutableArray array];
        for (NSDictionary* rec in recs){
            GRRecFeed* recFeed = [GRRecFeed recFeedsWithJSONObject:rec];
            GRSubscription* sub = [GRSubscription subscriptionForGRRecFeed:recFeed];
            [subs addObject:sub];
        }
        
        self.subscriptions = subs;
    }
    
    [self.delegate sourceLoadFinished];
}

@end
