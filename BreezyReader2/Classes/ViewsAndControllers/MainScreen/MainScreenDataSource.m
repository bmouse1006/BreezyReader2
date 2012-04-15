//
//  MainScreenDataSource.m
//  BreezyReader2
//
//  Created by 金 津 on 12-2-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MainScreenDataSource.h"
#import "BRSubGridViewController.h"
#import "BRSubFavoritePageController.h"
#import "BRRecommendationPageViewController.h"
#import "BRReadingStatistics.h"
#import "GRDataManager.h"

@interface MainScreenDataSource ()

@property (nonatomic, retain) NSArray* labelList;

@end

@implementation MainScreenDataSource

@synthesize controllers = _controllers;
@synthesize labelList = _labelList;

-(id)init{
    self = [super init];
    if (self){
        self.controllers = [NSMutableArray arrayWithCapacity:0];
    }
    
    return self;
}

-(void)dealloc{
    self.controllers = nil;
    self.labelList = nil;
    [super dealloc];
}

-(void)didReceiveMemoryWarning{
    [self.controllers makeObjectsPerformSelector:@selector(didReceiveMemoryWarning)];
}

-(void)superViewDidUnload{
    [self.controllers makeObjectsPerformSelector:@selector(viewDidUnload)];
}

-(void)reloadController{
    [self.controllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    [self.controllers removeAllObjects];
    self.labelList = [[GRDataManager shared] getLabelList];
    for (GRTag* tag in self.labelList){
        BRSubGridViewController* controller = [[[BRSubGridViewController alloc] init] autorelease];
        controller.tag = tag;
        [self.controllers addObject:controller];
    }
    
    BRSubGridViewController* controller = [[[BRSubGridViewController alloc] init] autorelease];
    GRTag* tag = [[[GRTag alloc] init] autorelease];
    tag.ID = @"";
    tag.label = NSLocalizedString(@"title_nolabel", nil);
    controller.tag = tag;
    [self.controllers addObject:controller];
    
    //load favorite page
    if ([[BRReadingStatistics statistics] countOfRecordedReadingFrequency] >= 6){
        BRSubFavoritePageController* favoritePage = [[[BRSubFavoritePageController alloc] init] autorelease];
        [self.controllers insertObject:favoritePage atIndex:0];
    }
    
    //load recommendation page
    BRRecommendationPageViewController* recPage = [[[BRRecommendationPageViewController alloc] init] autorelease];
    [self.controllers addObject:recPage];
    
}

-(NSInteger)numberOfContentViewsInScrollView:(InfinityScrollView *)scrollView{
    return [self.controllers count];
}

-(UIView*)scrollView:(InfinityScrollView *)scrollView contentViewAtIndex:(NSInteger)index{
    UIViewController* controller = [self.controllers objectAtIndex:index];
    return controller.view;
}

-(void)reload{
    [self reloadController];
}

@end
