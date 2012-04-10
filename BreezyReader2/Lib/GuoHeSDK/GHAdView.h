//
//  GHAdView.h
//  GuoHeProiOSDev
//
//  Created by Daniel Chen on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GHAdViewDelegate.h"
#import "GHBaseAdapter.h"

@interface GHAdView : UIView <UIWebViewDelegate>{
	
    id<GHAdViewDelegate> _delegate;
    
    // Ad Content parent view, added for close button.
    UIView *_adParentView;
	
}

@property (nonatomic, assign) id<GHAdViewDelegate> delegate;
@property (nonatomic, retain) UIView *adParentView;


//初始化广告位
- (id)initWithAdUnitId:(NSString *)adUnitId size:(CGSize)size;

//加载广告
- (void)loadAd;

//设置自定义定向字段
- (void)setCustomerTargetKey:(NSString *)theKey;

//暂停广告请求
- (void)stopAdRequest;

//恢复广告请求
- (void)resumeAdRequest;


// private method

- (void)adapter:(GHBaseAdapter *)adapter didFailToLoadAdWithError:(NSError *)error;
- (void)setAdContentView:(UIView *)view;
- (void)adapterDidFinishLoadingAd:(GHBaseAdapter *)adapter shouldTrackImpression:(BOOL)shouldTrack;
- (void)userActionWillBeginForAdapter:(GHBaseAdapter *)adapter;
- (void)userActionDidEndForAdapter:(GHBaseAdapter *)adapter;
- (void)userWillLeaveApplicationFromAdapter:(GHBaseAdapter *)adapter;

@end


