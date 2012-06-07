//
//  BRSearchDataSource.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "GoogleReaderClient.h"

@class BRSearchDataSource;

@protocol BRSearchProtocol <NSObject>

-(void)startSearchWithKeywords:(NSString*)keywords;

@end

@protocol BRSearchDelegate <NSObject>

-(void)dataSourceDidStartSearching:(BRSearchDataSource*)dataSource;
-(void)dataSourceDidFinishSearching:(BRSearchDataSource*)dataSource;
-(void)dataSourceDidLoadMore:(BRSearchDataSource*)dataSource;
-(void)dataSourceDidStartLoadMore:(BRSearchDataSource*)dataSource;

@end

@interface BRSearchDataSource : NSObject<BRSearchProtocol, UITableViewDataSource>{
    BOOL _searching;
}

@property (nonatomic, retain) NSMutableArray* results;
@property (nonatomic, retain) ASIHTTPRequest* request;

-(void)startSearchWithKeywords:(NSString*)keywords;
-(void)searchFinished;
-(void)loadMoreSearchResult;
-(id)objectAtIndexPath:(NSIndexPath*)indexPath;

-(BOOL)hasMore;
-(BOOL)isLoading;
-(BOOL)loaded;
-(BOOL)isLoadingMore;

@property (nonatomic, retain) GoogleReaderClient* client;
@property (nonatomic, copy) NSString* keywords;
@property (nonatomic, assign) NSObject<BRSearchDelegate>* delegate;

@end
