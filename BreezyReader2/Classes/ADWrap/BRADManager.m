//
//  BRADManager.m
//  BreezyReader2
//
//  Created by Jin Jin on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRADManager.h"
#import "UserPreferenceDefine.h"
#import "GHAdView.h"

@interface BRADManager ()

@property (nonatomic, retain) NSMutableSet* adSet;
@property (nonatomic, retain) NSMutableSet* loadedADSet;

@end

@implementation BRADManager

@synthesize adSet = _adSet;
@synthesize loadedADSet = _loadedADSet;

static NSString* GHUNITID = @"1f4b0d9d130afabeb578d0d522ed8f9a";

//static NSString* GHUNITID = @"ee942c110277be254c5f15e73a61394b";

+(id)sharedManager{
    static dispatch_once_t pred;
    __strong static BRADManager *obj = nil; 
    
    dispatch_once(&pred, ^{ 
        obj = [[BRADManager alloc] init]; 
    }); 
    
    return obj;
}

-(id)init{
    self = [super init];
    if (self){
        self.adSet = [NSMutableSet set];
        self.loadedADSet = [NSMutableSet set];
    }
    
    return self;
}

-(void)dealloc{
    self.adSet = nil;
    self.loadedADSet = nil;
    [super dealloc];
}

-(void)loadAD{
    //add a switch here to prevent loading ad
    if ([UserPreferenceDefine shouldLoadAD] == NO){
        return;
    }
    
    GHAdView* adView = [[GHAdView alloc] initWithAdUnitId:GHUNITID size:CGSizeMake(320, 50)];
    adView.delegate = self;
    [self.adSet addObject:adView];
    [adView loadAd];
}

-(GHAdView*)adView{
    if ([UserPreferenceDefine shouldLoadAD] == NO){
        return nil;
    }
    
    GHAdView* adView = [[[GHAdView alloc] initWithAdUnitId:GHUNITID size:CGSizeMake(320, 50)] autorelease];
//    adView.delegate = self;
    return adView;
}

-(UIViewController*)viewControllerForPresentingModalView{
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

-(void)adViewDidLoadAd:(GHAdView *)view{
    NSLog(@"ad is loaded");
    [self.loadedADSet addObject:view];
    [self.adSet removeObject:view];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADLOADED object:nil];
}

-(void)adViewDidFailToLoadAd:(GHAdView *)view{
    NSLog(@"ad is loaded failure");
}

-(UIView*)loadedAD{
    return [self.loadedADSet anyObject];
}


@end
