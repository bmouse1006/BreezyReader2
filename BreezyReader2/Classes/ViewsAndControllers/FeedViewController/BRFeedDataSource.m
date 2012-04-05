//
//  BRFeedDataSource.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "BRErrorHandler.h"
#import "BRFeedDataSource.h"
#import "BRFeedTableViewCell.h"
#import "SBJSON.h"
#import "BROperationQueues.h"
#import "BRReadingStatistics.h"

@interface BRFeedDataSource(){
    BOOL _loading;
    BOOL _loadingMore;
}

-(void)loadMoreFeedInBackground;

@end

@implementation BRFeedDataSource

@synthesize items = _items;
@synthesize subscription = _subscription, feed = _feed, moreFeed = _moreFeed;
@synthesize client = _client;

-(void)dealloc{
    [self.client clearAndCancel];
    self.client = nil;
    self.items = nil;
    self.subscription = nil;
    self.feed = nil;
    self.moreFeed = nil;
    [super dealloc];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.feed.items count];
}

-(id)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BRFeedTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"BRFeedTableViewCell"];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BRFeedTableViewCell" owner:nil options:nil] objectAtIndex:0];
    }
    
    GRItem* item = [self.feed getItemAtIndex:indexPath.row];
    [cell setItem:item];
    
    return cell;
}

-(void)loadDataMore:(BOOL)more forceRefresh:(BOOL)refresh{

    if (more){
        if ([self isLoadingMore]){
            return;
        }
        if (self.moreFeed && [self isLoadingMore] == NO){
            [self mergeCachedMoreData];
            [self.delegate dataSource:self didFinishLoading:YES];
            [self loadMoreFeedInBackground];
        }
    }else{
        [self.client clearAndCancel];
        self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(requestFeedIsLoaded:)];
        _loading = YES;
        [self.delegate dataSource:self didStartLoading:NO];
        [self.client requestFeedWithIdentifier:self.subscription.ID count:nil startFrom:nil exclude:nil continuation:nil forceRefresh:refresh];
        [[BRReadingStatistics statistics] readFeed:self.subscription.ID];
    }
}

-(void)loadMoreFeedInBackground{
    //start load more feed
    if ([self hasMore] && ![self isLoadingMore]){
        [self.client clearAndCancel];
        self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(moreFeedIsLoaded:)];

        [self.delegate dataSource:self didStartLoading:YES];
        _loadingMore = YES;
        DebugLog(@"continuation is %@", self.feed.gr_continuation);
        [self.client requestFeedWithIdentifier:self.subscription.ID count:nil startFrom:nil exclude:nil continuation:self.feed.gr_continuation forceRefresh:NO];
    }
}

-(BOOL)isLoading{
    return _loading;
}

-(BOOL)isLoaded{
    return (self.loadedTime != nil);
}

-(BOOL)isLoadingMore{
    return _loadingMore;
}

-(BOOL)isEmpty{
    return ([self.items count] != 0);
}

-(BOOL)hasMore{
    return (self.feed.gr_continuation.length > 0);
}

-(void)mergeCachedMoreData{
    [self.feed mergeWithFeed:self.moreFeed continued:YES];
    self.moreFeed = nil;
}

#pragma mark - delegate methods
-(void)requestFeedIsLoaded:(GoogleReaderClient*)client{
    if (client.error == nil){
        self.loadedTime = [NSDate date];
        GRFeed* feed = [GRFeed objWithJSON:client.responseJSONValue];
        self.feed = feed;
        _loading = NO;
        [self.delegate dataSource:self didFinishLoading:NO];
        [self loadMoreFeedInBackground];
    }else{
        [[BRErrorHandler sharedHandler] handleErrorMessage:[client.error localizedDescription]  alert:YES];
    }
}

-(void)moreFeedIsLoaded:(GoogleReaderClient*)client{
    if (client.error == nil){
        self.moreFeed = [GRFeed objWithJSON:client.responseJSONValue];
        _loadingMore = NO;
        [self.delegate dataSource:self didFinishLoading:YES];
    }else{
        [[BRErrorHandler sharedHandler] handleErrorMessage:[client.error localizedDescription]  alert:YES];
    }
}

@end
