//
//  GuoHeAdAdapter_Youmi.m
//  GuoHeSDKTest
//
//  Created by Daniel on 10-12-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GuoHeAdAdapter_Youmi.h"
#import "GHAdView.h"

@implementation GuoHeAdAdapter_Youmi
@synthesize youMiView = _youMiView;

- (void)dealloc
{
	_youMiView.delegate = nil;
	[_youMiView release];
	[super dealloc];
}

- (void)getAdWithParams:(NSString *)keyInfo adSize:(CGSize)adsize{
    YouMiBannerContentSizeIdentifier adSizeIndetifier = YouMiBannerContentSizeIdentifier320x50;
    if (adsize.width==320&&adsize.height==50) {
        adSizeIndetifier = YouMiBannerContentSizeIdentifier320x50;
    }else if (adsize.width==200&&adsize.height==200) {
        adSizeIndetifier = YouMiBannerContentSizeIdentifier200x200;
    }else if (adsize.width==300&&adsize.height==250) {
        adSizeIndetifier = YouMiBannerContentSizeIdentifier300x250;
    }else if (adsize.width==486&&adsize.height==60) {
        adSizeIndetifier = YouMiBannerContentSizeIdentifier468x60;
    }else if (adsize.width==728&&adsize.height==90) {
        adSizeIndetifier = YouMiBannerContentSizeIdentifier728x90;
    }else{
        GHLogWarn(@"App YouMi size wrong..");
        adSizeIndetifier = YouMiBannerContentSizeIdentifierUnknow;
    }
    self.youMiView = [[[YouMiView alloc] initWithContentSizeIdentifier:adSizeIndetifier delegate:self] autorelease];
    NSArray *keyArray = [keyInfo componentsSeparatedByString:@"|;|"];
    if ([keyArray count]>1) {
        _youMiView.appID = [keyArray objectAtIndex:0];
        _youMiView.appSecret = [keyArray objectAtIndex:1];
        [_youMiView start];
        
    } else {
        GHLogWarn(@"App YouMi key null..");
    }
	
}


#pragma mark implement YouMiDelegate methods
- (void)didReceiveAd:(YouMiView *)adView
{
    [self.adView setAdContentView:_youMiView];
	[self.adView adapterDidFinishLoadingAd:self shouldTrackImpression:YES];
}

// 请求广告条数据失败后调用
// 
// 详解:当接收服务器返回的广告数据失败后调用该函数
// 补充：第一次和接下来每次如果请求失败都会调用该函数
- (void)didFailToReceiveAd:(YouMiView *)adView  error:(NSError *)error
{
    [self.adView adapter:self didFailToLoadAdWithError:nil];
}

#pragma mark Click-Time Notifications Methods

// 将要显示全屏广告前调用
// 
// 详解:将要显示一次全屏广告内容前调用该函数
- (void)willPresentScreen:(YouMiView *)adView
{
    [self.adView userActionWillBeginForAdapter:self];
}

// 显示全屏广告成功后调用
//
// 详解:显示一次全屏广告内容后调用该函数
- (void)didPresentScreen:(YouMiView *)adView
{
    
}

// 将要关闭全屏广告前调用
//
// 详解:全屏广告将要关闭前调用该函数
- (void)willDismissScreen:(YouMiView *)adView
{
    [self.adView userActionDidEndForAdapter:self];
}

// 成功关闭全屏广告后调用
//
// 详解:全屏广告显示完成，关闭全屏广告后调用该函数
- (void)didDismissScreen:(YouMiView *)adView
{
    
}

@end
