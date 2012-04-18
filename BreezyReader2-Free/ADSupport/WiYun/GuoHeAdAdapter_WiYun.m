//
//  GuoHeAdAdapter_WiYun.m
//  GuoHeProiOSDev
//
//  Created by Wulin on 03/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GuoHeAdAdapter_WiYun.h"
#import "GHAdView.h"

@implementation GuoHeAdAdapter_WiYun
@synthesize adBannerView = _adBannerView;

- (void)dealloc
{
    [_adBannerView removeGestureRecognizer:_nonListenerGR];
    [_nonListenerGR release];
    [_adBannerView release];
    [super dealloc];
}

- (void)getAdWithParams:(NSString *)keyInfo adSize:(CGSize)adsize
{
    NSArray *keyArray = [keyInfo componentsSeparatedByString:@"|;|"];
    if ([keyArray count] > 0) {
        self.adBannerView = [WiAdView adViewWithResId:[keyArray objectAtIndex:0] style:kWiAdViewStyleBanner320_50];
        self.adBannerView.delegate = self;
        //---------- begin: add codes for non-listener ad network track click data
        if (_nonListenerGR==nil) {
            _nonListenerGR = [[UITapGestureRecognizer alloc] initWithTarget:self.adView action:@selector(nonListenerNetworkAdClicked)];
        }        
        _nonListenerGR.delegate = self;
        [_nonListenerGR setNumberOfTapsRequired:1];
        [_nonListenerGR setNumberOfTouchesRequired:1];
        [_nonListenerGR setCancelsTouchesInView:NO];
        [_adBannerView addGestureRecognizer:_nonListenerGR];
        //----------- end
        [_adBannerView requestAd];
    }
}

- (BOOL)WiAdUseTestMode:(WiAdView*)adView{
    //返回是否使用测试模式
    return NO;
}

- (int)WiAdTestAdType:(WiAdView *)adView
{
    return TEST_WIAD_TYPE_BANNER;
}

- (void)WiAdDidLoad:(WiAdView *)adView
{
    [self.adView setAdContentView:_adBannerView];
	[self.adView adapterDidFinishLoadingAd:self shouldTrackImpression:YES];
}

- (void)WiAdDidFailLoad:(WiAdView *)adView
{
    [self.adView adapter:self didFailToLoadAdWithError:nil];
}

///ad click gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return  YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return  YES;
}

@end
