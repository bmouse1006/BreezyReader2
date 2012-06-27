//
//  JJAdView.h
//  BreezyReader2
//
//  Created by 津 金 on 12-6-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"
#import <iAd/iAd.h>
#import <CoreLocation/CoreLocation.h>

@class JJAdView;

@protocol JJAdViewDelegate <NSObject>

-(void)adViewDidLoadAd:(JJAdView *)view;
-(void)adViewDidFailToLoadAd:(JJAdView *)view;
-(BOOL)shouldLoadiAd;
-(UIViewController*)viewControllerForPresentingModalView;
-(CLLocation*)locationInfo;

@end

@interface JJAdView : UIView<ADBannerViewDelegate, GADBannerViewDelegate>

@property (nonatomic, assign) id<JJAdViewDelegate> delegate;

@property (nonatomic, copy) NSString* adMobPublisherID;

-(id)initWithSize:(CGSize)adSize;

-(void)loadAd;
-(void)resumeAdRequest;
-(void)stopAdRequest;

@end
