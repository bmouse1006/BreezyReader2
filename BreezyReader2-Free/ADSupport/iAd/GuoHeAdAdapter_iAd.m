//
//  GuoHeAdAdapter_iAd.m
//  WeiboXL Lite
//
//  Created by Daniel on 11-3-8.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GuoHeAdAdapter_iAd.h"
#import "GHAdView.h"

@implementation GuoHeAdAdapter_iAd

- (void)dealloc
{
	_adBannerView.delegate = nil;
    [_adBannerView release];
	[super dealloc];
}


- (void)getAdWithParams:(NSString *)keyInfo adSize:(CGSize)adsize
{
	//get system ios version
	float ios_vesion = [[UIDevice currentDevice].systemVersion floatValue];
	if (ios_vesion>=4.0) {
		_adBannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
        _adBannerView.frame = CGRectMake(self.adView.frame.origin.x, self.adView.frame.origin.y, adsize.width, adsize.height);
		
		_adBannerView.delegate = self;
		_adBannerView.hidden = YES;
	}
	else {
		GHLogInfo(@"ios version is lower than 4.0");
	}
}



#pragma mark -
#pragma	mark ADBannerViewDelegate

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	GHLogInfo(@"iAd failed in trying to load or refresh an ad.");
	[self.adView adapter:self didFailToLoadAdWithError:error];
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
	GHLogInfo(@"iAd finished executing banner action.");
	[self.adView userActionDidEndForAdapter:self];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
	GHLogInfo(@"iAd should begin banner action.");
	[self.adView userActionWillBeginForAdapter:self];
	if (willLeave) 
        [self.adView userWillLeaveApplicationFromAdapter:self];
	return YES;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	GHLogInfo(@"iAd has successfully loaded a new ad.");
	[self.adView setAdContentView:_adBannerView];
	[self.adView adapterDidFinishLoadingAd:self shouldTrackImpression:YES];
}

@end
