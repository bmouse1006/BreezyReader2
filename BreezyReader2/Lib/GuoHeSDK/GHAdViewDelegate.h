//
//  GHAdViewDelegate.h
//  GuoHeProiOSDev
//
//  Created by Daniel Chen on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class GHAdView;

@protocol GHAdViewDelegate <NSObject>

@required
// 设置广告位的ViewController
- (UIViewController *)viewControllerForPresentingModalView;

@optional
//加载广告失败时调用
- (void)adViewDidFailToLoadAd:(GHAdView *)view;

//加载广告成功时调用
- (void)adViewDidLoadAd:(GHAdView *)view;

//广告点击出现内容窗口时调用
- (void)willPresentModalViewForAd:(GHAdView *)view;

//广告内容窗口关闭时调用
- (void)didDismissModalViewForAd:(GHAdView *)view;

//设置用户当前位置的方法
- (CLLocation *)locationInfo;

//广告位的关闭按钮被点击时调用
- (void)didClosedAdView:(GHAdView *)view;

@end
