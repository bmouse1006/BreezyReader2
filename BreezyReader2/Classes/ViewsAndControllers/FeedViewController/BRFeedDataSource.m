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
#import "BROperationQueues.h"
#import "BRReadingStatistics.h"
#import "BRImagePreviewCache.h"

@interface BRFeedDataSource(){
    BOOL _loading;
    BOOL _loadingMore;
}

-(void)loadMoreFeedInBackground;

@end

@implementation BRFeedDataSource

@synthesize subscription = _subscription, feed = _feed, moreFeed = _moreFeed;
@synthesize client = _client;
@synthesize unreadOnly = _unreadOnly;
@synthesize exclude = _exclude;

-(void)dealloc{
    [self.client clearAndCancel];
}

-(void)setUnreadOnly:(BOOL)unreadOnly{
    if (_unreadOnly != unreadOnly){
        self.moreFeed = nil;
        _unreadOnly = unreadOnly;
        if (_unreadOnly){
            self.exclude = [GoogleReaderClient readArticleTag];
        }else{
            self.exclude = nil;
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.feed.items count];
}

-(id)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BRFeedTableViewCell* cell = nil;
    if (indexPath.row % 10 == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"BRFeedHeaderArticleCell"];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BRFeedHeaderArticleCell" owner:nil options:nil] objectAtIndex:0];
            cell.showSource = ![self.subscription isStream];
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"BRFeedTableViewCell"];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BRFeedTableViewCell" owner:nil options:nil] objectAtIndex:0];
            cell.showSource = ![self.subscription isStream];
        }
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
        [self.client requestFeedWithIdentifier:self.subscription.ID count:nil startFrom:nil exclude:self.exclude continuation:nil forceRefresh:refresh needAuth:YES priority:NSOperationQueuePriorityVeryHigh];
        if([GoogleReaderClient subscriptionWithID:self.subscription.ID]){
            [[BRReadingStatistics statistics] readFeed:self.subscription.ID];
        }
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
        [self.client requestFeedWithIdentifier:self.subscription.ID count:nil startFrom:nil exclude:self.exclude continuation:self.feed.gr_continuation forceRefresh:NO needAuth:YES priority:NSOperationQueuePriorityVeryHigh];
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
    return ([self.feed.items count] == 0);
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
        GRFeed* feed = client.responseFeed;
        self.feed = feed;
        //refresh image URL
        NSArray* imageURLs = [feed imageURLs];
        if ([imageURLs count] > 0){
            [[BRImagePreviewCache sharedCache] storeImagePreviews:[feed imageURLs] key:self.subscription.ID];
        }
        if (client.didUseCachedData == NO){
            [[BRReadingStatistics statistics] refreshFeed:self.subscription.ID];
        }
        _loading = NO;
        [self.delegate dataSource:self didFinishLoading:NO];
        [self loadMoreFeedInBackground];
    }else{
        [[BRErrorHandler sharedHandler] handleErrorMessage:NSLocalizedString([client.error localizedDescription], nil)  alert:YES];
    }
}

-(void)moreFeedIsLoaded:(GoogleReaderClient*)client{
    if (client.error == nil){
        self.moreFeed = client.responseFeed;
        _loadingMore = NO;
        [self.delegate dataSource:self didFinishLoading:YES];
    }else{
        [[BRErrorHandler sharedHandler] handleErrorMessage:NSLocalizedString([client.error localizedDescription], nil)  alert:YES];
    }
}

@end
