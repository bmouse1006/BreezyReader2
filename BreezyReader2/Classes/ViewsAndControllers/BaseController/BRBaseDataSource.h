//
//  BRBaseDataSource.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BRBaseDataSource;

@protocol BRBaseDataSourceDelegate <NSObject>

-(void)dataSource:(BRBaseDataSource*)dataSource didFinishLoading:(BOOL)more;
-(void)dataSource:(BRBaseDataSource*)dataSource didStartLoading:(BOOL)more;

@end

@interface BRBaseDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, assign) id<BRBaseDataSourceDelegate> delegate;
@property (nonatomic, retain) NSDate* loadedTime;

-(void)loadDataMore:(BOOL)more forceRefresh:(BOOL)refresh;
-(void)mergeCachedMoreData;
-(BOOL)isLoading;
-(BOOL)isLoadingMore;
-(BOOL)isLoaded;
-(BOOL)isEmpty;
-(BOOL)hasMore;

-(void)finishedLoading:(BOOL)more;

@end
