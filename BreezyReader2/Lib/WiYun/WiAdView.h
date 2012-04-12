/* 
 * Copyright (c) 2009, WiYun Inc.
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the WiYun Inc. nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE OPYRIGHT HOLDER AND CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>

@class WiAdCommonView, WiAdShiningLabel;

//广告类型
#define	TEST_WIAD_TYPE_TEXT               1
#define	TEST_WIAD_TYPE_BANNER	          2
#define	TEST_WIAD_TYPE_BANNER_IMAGE	      3
#define	TEST_WIAD_TYPE_FULL_SCREEN	      4

@class WiAdView;

/**
 * WiAdView Delegate 协议
 */
@protocol WiAdViewDelegate

@optional

//告诉WiAdView是否使用测试模式
- (BOOL)WiAdUseTestMode:(WiAdView*)adView;

//告诉WiAdView使用哪种测试广告类型
- (int)WiAdTestAdType:(WiAdView*)adView;

//广告加载成功时调用
- (void)WiAdDidLoad:(WiAdView*)adView;

//广告加载失败时调用
- (void)WiAdDidFailLoad:(WiAdView*)adView;

//全屏广告关闭按钮点击时调用
- (void)WiAdFullScreenAdSkipped:(WiAdView*)adView;

//全屏广告被点击后调用
- (void)WiAdFullScreenAdClicked:(WiAdView*)adView;

@end

typedef enum _WiAdViewStyle{
    kWiAdViewStyleBanner320_50,
    kWiAdViewStyleBanner320_270,
    kWiAdViewStyleBanner508_80,
    kWiAdViewStyleBanner768_110,
    kWiAdViewStyleFullscreen,
} WiAdViewStyle;

/*
 * WiAd广告视图类
 */
@class WiAdLayout;
@interface WiAdView : UIView {	
	
@private
    //内部对象
	WiAdCommonView* _adContainer;
	WiAdShiningLabel* _loadingLabel;
	BOOL _hideWhenNoAd;
	BOOL _requestingAd;
    NSTimer* _scheduledTimer;
    NSTimeInterval _lastRefreshTime;
    WiAdLayout* _layout;

    WiAdViewStyle _adViewStyle;
	NSString* _resId;
	UIColor* _adBgColor;
	UIColor* _adTextColor;
    UIFont* _adTextFont;
	NSTimeInterval _refreshInterval;
	BOOL _useExternalBrowser;
	id _delegate;
}

//delegate对象
@property (nonatomic, assign) IBOutlet id delegate;
//广告位布局分格
@property (nonatomic, assign) WiAdViewStyle adViewStyle;
//广告ID
@property (nonatomic, retain) NSString* resId;
//广告文本颜色
@property (nonatomic, retain) UIFont* adTextFont;
//广告文本颜色
@property (nonatomic, retain) UIColor* adTextColor;
//广告背景颜色
@property (nonatomic, retain) UIColor* adBgColor;
//广告刷新时间
@property (nonatomic, assign) NSTimeInterval refreshInterval;

// 创建广告视图对象
+ (WiAdView*)adViewWithResId:(NSString*)resId style:(WiAdViewStyle)style;


// 开始请求广告
- (void)requestAd;

@end