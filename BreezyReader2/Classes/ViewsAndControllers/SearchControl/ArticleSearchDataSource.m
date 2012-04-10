//
//  ArticleSearchDataSource.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ArticleSearchDataSource.h"
#import "SearchLoadingCell.h"

#define kPageSize 10

@interface ArticleSearchDataSource(){
    NSInteger _startIndex;
}

@property (nonatomic, retain) NSArray* searchResults;

-(void)requestContentsForIDs:(NSArray*)IDs;
-(void)loadNextPageOfContents;

@end

@implementation ArticleSearchDataSource

@synthesize searchResults = _searchResults;
@synthesize feed = _feed;

-(id)init{
    self = [super init];
    if (self){
        _startIndex = 0;
    }
    
    return self;
}

-(void)dealloc{
    self.searchResults = nil;
    self.feed = nil;
    [super dealloc];
}

-(id)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id cell = nil;
    if (_searching){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchLoadingCell" owner:nil options:nil] objectAtIndex:0];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"BRFeedTableViewCell"];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BRFeedTableViewCell" owner:nil options:nil] objectAtIndex:0];
        }
        
        [cell performSelector:@selector(setItem:) withObject:[self.results objectAtIndex:indexPath.row]];
    }
    return cell;
}

-(void)startSearchWithKeywords:(NSString *)keywords{
    [super startSearchWithKeywords:keywords];
    _startIndex = 0;
    self.results = nil;
    self.searchResults = nil;
    self.feed = nil;
    
    [self.client clearAndCancel];
    self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(receivedSearchingResult:)];
    [self.client searchArticlesWithKeywords:keywords];
}

-(NSString*)title{
    return @"Searching ariticles...";
}

-(void)receivedSearchingResult:(GoogleReaderClient*)client{
    if (client.error == nil){
        self.searchResults = [client.responseJSONValue objectForKey:@"results"];
        [self loadNextPageOfContents];
    }
}

-(void)loadNextPageOfContents{
    NSInteger pageSize = MIN(kPageSize, [self.searchResults count] - _startIndex);
    NSRange range = {_startIndex, pageSize};
    if (pageSize == 0){
        [self searchFinished];
        return;
    }
    NSArray* IDs = [self.searchResults subarrayWithRange:range];
    _startIndex += pageSize;
    
    if ([self.results count] > 0){
        [self.delegate performSelectorOnMainThread:@selector(dataSourceDidStartLoadMore:) withObject:self waitUntilDone:NO];
    }
    
    [self requestContentsForIDs:IDs];
}

-(void)requestContentsForIDs:(NSArray*)IDs{ 
    [self.client clearAndCancel];
    self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(receivedContents:)];
    [self.client queryContentsWithIDs:IDs];
}

-(void)receivedContents:(GoogleReaderClient*)client{
    if (client.error == nil){
        GRFeed* feed = client.responseFeed;
        if (!self.feed){
            self.feed = feed;
        }else{
            [self.feed mergeWithFeed:feed continued:YES];
        }
        self.results = self.feed.items; 
        [self searchFinished];
    }else{
        //error handler
    }
}

-(BOOL)hasMore{
    return ([self.searchResults count] - _startIndex) > kPageSize;
}

-(void)loadMoreSearchResult{
    [self loadNextPageOfContents];
}

-(BOOL)isLoading{
    return [self.client isLoading];
}

@end
