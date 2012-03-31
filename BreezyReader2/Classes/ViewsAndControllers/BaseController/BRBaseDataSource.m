//
//  BRBaseDataSource.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRBaseDataSource.h"

@implementation BRBaseDataSource

@synthesize delegate = _delegate;
@synthesize loadedTime = _loadedTime;

-(void)dealloc{
    self.loadedTime = nil;
    [super dealloc];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

-(id)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

-(BOOL)hasMore{
    return NO;
}

-(BOOL)isLoading{
    return NO;
}

-(BOOL)isLoadingMore{
    return NO;
}

-(BOOL)isLoaded{
    return YES;
}
-(BOOL)isEmpty{
    return NO;
}

-(void)loadDataMore:(BOOL)more forceRefresh:(BOOL)refresh{
    [self.delegate dataSource:self didFinishLoading:more];
}

-(void)finishedLoading:(BOOL)more{
    
}

-(void)mergeCachedMoreData{
    
}

@end
