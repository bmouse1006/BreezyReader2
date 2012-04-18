//
//  YouMiSpotDelegateProtocol.h
//  YouMiView
//
//  Created by Layne on 10-11-30.
//  Copyright 2010 www.youmi.net. All rights reserved.
//

#import <UIKit/UIKit.h>


@class YouMiSpot;

@protocol YouMiSpotDelegate<NSObject>

@optional

#pragma mark Spot Request and Load Notification Methods

// 请求插播广告成功后调用
//
// 详解:当接收服务器返回的插播广告数据成功后调用该函数
- (void)didReceiveSpotAd:(YouMiSpot *)adSpot;

// 请求插播广告失败后调用
// 
// 详解:当接收服务器返回的插播广告数据失败后调用该函数
- (void)didFailToReceiveSpotAd:(YouMiSpot *)adSpot;

// 加载插播广告内容成功后调用
//
// 详解:插播广告数据请求成功后，加载插播广告的内容，若成功则调用该函数
- (void)didFinishLoadSpotAd:(YouMiSpot *)adSpot;

// 加载插播广告内容失败后调用
//
// 详解:插播广告数据请求成功后，加载插播广告的内容，若失败则调用该函数
- (void)didFailToFinishLoadSpotAd:(YouMiSpot *)adSpot;

#pragma mark Show-Spot Notifications Methods

// 将要显示插播广告前调用
// 
// 详解:将要显示一次插播广告内容前调用该函数
- (void)willShowSpotAd:(YouMiSpot *)adSpot;

// 显示插播广告成功后调用
//
// 详解:显示一次插播广告内容后调用该函数
- (void)didShowSpotAd:(YouMiSpot *)adSpot;

// 将要关闭插播广告前调用
//
// 详解:插播广告显示完成，将要关闭插播广告前调用该函数
- (void)willDismissSpotAd:(YouMiSpot *)adSpot;

// 成功关闭插播广告后调用
//
// 详解:插播广告显示完成，关闭插播广告后调用该函数
- (void)didDismissSpotAd:(YouMiSpot *)adSpot;

@end