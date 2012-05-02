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
#import "GoogleReaderClient.h"

@interface MainScreenDataSource ()

@property (nonatomic, retain) NSMutableSet* tagIDSet;
@property (nonatomic, retain) NSMutableDictionary* tagControllers;

@property (nonatomic, retain) BRRecommendationPageViewController* recommendationPage;
@property (nonatomic, retain) BRSubFavoritePageController* favoritePage;

@end

@implementation MainScreenDataSource

@synthesize controllers = _controllers;
@synthesize tagIDSet = _tagIDSet, tagControllers = _tagControllers;
@synthesize recommendationPage = _recommendationPage, favoritePage = _favoritePage;

-(id)init{
    self = [super init];
    if (self){
        self.controllers = [NSMutableArray arrayWithCapacity:0];
        self.tagIDSet = [NSMutableSet set];
        self.tagControllers = [NSMutableDictionary dictionary];
    }
    
    return self;
}

-(void)dealloc{
    self.controllers = nil;
    self.tagIDSet = nil;
    self.recommendationPage = nil;
    self.favoritePage = nil;
    self.tagControllers = nil;
    [super dealloc];
}

-(void)didReceiveMemoryWarning{
    [self.controllers makeObjectsPerformSelector:@selector(didReceiveMemoryWarning)];
}

-(void)superViewDidUnload{
    [self.controllers makeObjectsPerformSelector:@selector(viewDidUnload)];
}

-(void)reloadController{

    NSMutableArray* allLabels = [NSMutableArray arrayWithArray:[GoogleReaderClient tagListWithType:BRTagTypeLabel]];
    GRTag* emptyLabel = [GRTag tagWithNoLabel];
    [allLabels addObject:emptyLabel];
    
    NSSet* showedLabels = [NSSet setWithSet:self.tagIDSet];
    
//    self.tagList = tags;
    [showedLabels enumerateObjectsUsingBlock:^(id obj, BOOL* stop){
        NSString* tagID = obj;
        if ([[GoogleReaderClient subscriptionsWithTagID:tagID] count] == 0){
            [self.tagIDSet removeObject:tagID];
            [self.tagControllers removeObjectForKey:tagID];
        }
    }];
    
    [allLabels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop){
        GRTag* tag = obj;
        if ([[GoogleReaderClient subscriptionsWithTagID:tag.ID] count] > 0 && [self.tagIDSet containsObject:tag.ID] == NO){
            [self.tagIDSet addObject:tag.ID];
            BRSubGridViewController* controller = [[[BRSubGridViewController alloc] init] autorelease];
            controller.tag = tag;
            [self.tagControllers setObject:controller forKey:tag.ID];
        }
    }];
    
    //load favorite page
    if (self.favoritePage == nil){
        if ([[BRReadingStatistics statistics] countOfRecordedReadingFrequency] >= 6){
            self.favoritePage = [[[BRSubFavoritePageController alloc] init] autorelease];
        }else{
            self.favoritePage = nil;
        }
    }
    //load recommendation page
    if (self.recommendationPage == nil){
        self.recommendationPage = [[[BRRecommendationPageViewController alloc] init] autorelease];
    }
    
    [self composeControllerList];
}

-(void)composeControllerList{
    [self.controllers removeAllObjects];
    if (self.favoritePage){
        [self.controllers addObject:self.favoritePage];
    }
    
    NSArray* sortedKeys = [[self.tagControllers allKeys] sortedArrayUsingComparator:^(id obj1, id obj2){
        NSString* sortID1 = [GoogleReaderClient tagWithID:obj1].sortID;
        sortID1 = (sortID1.length==0)?@"ZZZZZZZ":sortID1;
        NSString* sortID2 = [GoogleReaderClient tagWithID:obj2].sortID;
        sortID2 = (sortID2.length==0)?@"ZZZZZZZ":sortID2;
        return [sortID1 compare:sortID2];
    }];
    
    [sortedKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop){
        [self.controllers addObject:[self.tagControllers objectForKey:obj]];
    }];

    if (self.recommendationPage){
        [self.controllers addObject:self.recommendationPage];
    }
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

-(BRSubGridViewController*)controllerForTag:(NSString*)tagID{
    for (BRSubGridViewController* controller in self.controllers){
        if ([controller respondsToSelector:@selector(tag)]){
            if ([controller.tag.ID isEqualToString:tagID]){
                return controller;
            }
        }
    }
    
    return nil;
}

@end
