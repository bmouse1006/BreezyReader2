//
//  YouMiDelegateProtocol.h
//  YouMiAdView
//
//  Created by Layne on 10-8-31.
//  Copyright 2010 www.youmi.net. All rights reserved.
//

#import <UIKit/UIKit.h>


@class YouMiView;

@protocol YouMiDelegate <NSObject>

@optional

#pragma mark Ad Request Notification Methods

// 请求广告条数据成功后调用
//
// 详解:当接收服务器返回的广告数据成功后调用该函数
// 补充：第一次返回成功数据后调用
- (void)didReceiveAd:(YouMiView *)adView;

// 请求广告条数据失败后调用
// 
// 详解:当接收服务器返回的广告数据失败后调用该函数
// 补充：第一次和接下来每次如果请求失败都会调用该函数
- (void)didFailToReceiveAd:(YouMiView *)adView  error:(NSError *)error;

#pragma mark Click-Time Notifications Methods

// 将要显示全屏广告前调用
// 
// 详解:将要显示一次全屏广告内容前调用该函数
- (void)willPresentScreen:(YouMiView *)adView;

// 显示全屏广告成功后调用
//
// 详解:显示一次全屏广告内容后调用该函数
- (void)didPresentScreen:(YouMiView *)adView;

// 将要关闭全屏广告前调用
//
// 详解:全屏广告将要关闭前调用该函数
- (void)willDismissScreen:(YouMiView *)adView;

// 成功关闭全屏广告后调用
//
// 详解:全屏广告显示完成，关闭全屏广告后调用该函数
- (void)didDismissScreen:(YouMiView *)adView;

@end
