//
//  JJADManager.m
//  BreezyReader2
//
//  Created by Jin Jin on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJADManager.h"
#import "BRUserPreferenceDefine.h"
#import "ASIHTTPRequest.h"

static NSString* LOCATION_API = @"http://api.wipmania.com/";

@interface JJADManager ()

@property (nonatomic, retain) CLLocation* location;

@end

@implementation JJADManager

@synthesize location = _location;

//static NSString* GHUNITID = @"1f4b0d9d130afabeb578d0d522ed8f9a";
static BOOL inChina = YES;

+(void)checkCurrentCountry{
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:LOCATION_API]];
    
    [request setCompletionBlock:^{
        if (request.error == nil){
            if ([request.responseString rangeOfString:@"CN"].length > 0){
                inChina = YES;
            }else{
                inChina = NO;
            }
        }
    }];
    
    [request startAsynchronous];
}

+(id)sharedManager{
    static dispatch_once_t pred;
    __strong static JJADManager *obj = nil; 
    
    dispatch_once(&pred, ^{ 
        obj = [[JJADManager alloc] init]; 
    }); 
    
    return obj;
}

-(id)init{
    self = [super init];
    if (self){
#ifdef FREEVERSION
        CLLocationManager* manager = [[CLLocationManager alloc] init];
        manager.delegate = self;
        [manager startUpdatingLocation];
#endif
    }
    
    return self;
}

-(void)dealloc{
    self.location = nil;
    [super dealloc];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    self.location = newLocation;
    [manager stopUpdatingLocation];
}

-(UIView*)adView{
//    if ([BRUserPreferenceDefine shouldLoadAD] == NO){
//        return nil;
//    }
    JJAdView* adView = nil;
#ifdef FREEVERSION
    adView = [[[JJAdView alloc] initWithSize:CGSizeMake(320, 50)] autorelease];
    adView.hidden = YES;
    adView.delegate = self;
    [adView loadAd];
//    adView = [[[GHAdView alloc] initWithAdUnitId:GHUNITID size:CGSizeMake(320, 50)] autorelease];
//    ((GHAdView*)adView).delegate = self;
//    adView.hidden = YES;
//    [(GHAdView*)adView loadAd];
#endif
    
    return adView;
}

-(UIViewController*)viewControllerForPresentingModalView{
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

-(void)adViewDidLoadAd:(UIView *)view{
    NSLog(@"ad is loaded");
    view.hidden = NO;
}

-(void)adViewDidFailToLoadAd:(UIView *)view{
    NSLog(@"ad is loaded failure");
}

- (CLLocation *)locationInfo{
    return self.location;
}

-(BOOL)shouldLoadiAd{
    return inChina == NO;
}

@end
