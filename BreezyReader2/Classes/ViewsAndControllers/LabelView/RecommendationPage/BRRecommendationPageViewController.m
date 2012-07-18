//
//  BRRecommendationPageViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRRecommendationPageViewController.h"
#import "BRRecommendationDataSource.h"
#import "GoogleReaderClientHelper.h"

@interface BRRecommendationPageViewController ()

@end

@implementation BRRecommendationPageViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    [self.source loadSourceMore:NO];
}

-(void)createSource{
    self.source = [[BRRecommendationDataSource alloc] init];
    self.source.delegate = self;
}

-(void)mediaLibTableViewCell:(JJMediaLibTableViewCell *)cell didSelectMediaAtIndex:(NSInteger)index{
    [super mediaLibTableViewCell:cell didSelectMediaAtIndex:index];
    GRSubscription* sub = [self.source mediaAtIndex:index];
    GoogleReaderClient* client = [GoogleReaderClientHelper client];
    [client viewRecommendationStream:sub.ID];
}

-(void)viewWillAppear:(BOOL)animated{
    if ([GoogleReaderClient needRefreshReaderStructure]){
        
    }
}

#pragma mark - data source delegate
-(void)sourceStartLoading{
    
}

-(void)sourceLoadFinished{
    [super sourceLoadFinished];
    //remove 'waiting' page
}

@end
