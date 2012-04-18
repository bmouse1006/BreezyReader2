//
//  BRRecommendationPageViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRRecommendationPageViewController.h"
#import "BRRecommendationDataSource.h"
#import "GoogleReaderClient.h"

@interface BRRecommendationPageViewController ()

@property (nonatomic, retain) GoogleReaderClient* client;

@end

@implementation BRRecommendationPageViewController

@synthesize client = _client;

-(void)dealloc{
    [self.client clearAndCancel];
    self.client = nil;
    [super dealloc];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.client = [GoogleReaderClient clientWithDelegate:nil action:NULL];
}

-(void)createSource{
    self.source = [[[BRRecommendationDataSource alloc] init] autorelease];
    self.source.delegate = self;
}

-(void)mediaLibTableViewCell:(JJMediaLibTableViewCell *)cell didSelectMediaAtIndex:(NSInteger)index{
    [super mediaLibTableViewCell:cell didSelectMediaAtIndex:index];
    GRSubscription* sub = [self.source mediaAtIndex:index];
    [self.client viewRecommendationStream:sub.ID];
}

#pragma mark - data source delegate
-(void)sourceStartLoading{
    
}

-(void)sourceLoadFinished{
    [super sourceLoadFinished];
    //remove 'waiting' page
}

@end
