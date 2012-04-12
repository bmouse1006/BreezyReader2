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

@property (nonatomic, assign) CLLocation* location;

@end

@implementation BRADManager

@synthesize location;

static NSString* GHUNITID = @"1f4b0d9d130afabeb578d0d522ed8f9a";

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
        CLLocationManager* manager = [[CLLocationManager alloc] init];
        manager.delegate = self;
        [manager startUpdatingLocation];
    }
    
    return self;
}

-(void)dealloc{
    self.location = nil;
    [super dealloc];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    self.location = location;
    [manager stopUpdatingLocation];
}

-(GHAdView*)adView{
    if ([UserPreferenceDefine shouldLoadAD] == NO){
        return nil;
    }
    
    GHAdView* adView = [[[GHAdView alloc] initWithAdUnitId:GHUNITID size:CGSizeMake(320, 50)] autorelease];
    adView.delegate = self;
    adView.hidden = YES;
    [adView loadAd];
    return adView;
}

-(UIViewController*)viewControllerForPresentingModalView{
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

-(void)adViewDidLoadAd:(GHAdView *)view{
    NSLog(@"ad is loaded");
    view.hidden = NO;
}

-(void)adViewDidFailToLoadAd:(GHAdView *)view{
    NSLog(@"ad is loaded failure");
}

- (CLLocation *)locationInfo{
    return self.location;
}

@end
