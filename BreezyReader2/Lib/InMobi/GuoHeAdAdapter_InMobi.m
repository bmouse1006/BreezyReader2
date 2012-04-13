//
//  GuoHeAdAdapter_InMobi.m
//  GuoHeProiOSDev
//
//  Created by Daniel on 30/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GuoHeAdAdapter_InMobi.h"
#import "GHAdView.h"

@implementation GuoHeAdAdapter_InMobi
@synthesize adBannerView = _adBannerView;

- (void)dealloc
{
	[_adBannerView setDelegate:nil];
	[_adBannerView release];
    _adBannerView = nil;
	[super dealloc];
}

- (int)computeImAdUnit:(CGSize)adsize
{
    if (adsize.width == 120) {
        return IM_UNIT_120x600;
    } else if (adsize.width == 300) {
        return IM_UNIT_300x250;
    } else if (adsize.width == 320) {
        return IM_UNIT_320x50;
    } else if (adsize.width == 468) {
        return IM_UNIT_468x60;
    } else if (adsize.width == 728) {
        return IM_UNIT_728x90;
    } else {
        GHLogWarn(@"App InMobi size wrong..");
        return -1;
    }
}

- (void)getAdWithParams:(NSString *)keyInfo adSize:(CGSize)adsize
{
	NSArray *keyArray = [keyInfo componentsSeparatedByString:@"|;|"];
    if ([keyArray count]>1) {
        CGRect frame = CGRectMake(self.adView.adParentView.frame.origin.x, self.adView.adParentView.frame.origin.y, adsize.width, adsize.height);
        self.adBannerView = [[[IMAdView alloc] initWithFrame:frame imAppId:[keyArray objectAtIndex:0] imAdUnit:[self computeImAdUnit:adsize] rootViewController:[self.adView.delegate viewControllerForPresentingModalView]] autorelease];
        
        [_adBannerView setDelegate: self];
        _adBannerView.refreshInterval = REFRESH_INTERVAL_OFF;
        
        IMAdRequest *request = [IMAdRequest request];
        
        NSString *strTest = [keyArray objectAtIndex:1];
        if ([strTest compare:@"true"]==NSOrderedSame) {
            request.testMode = YES;
        } else {
            request.testMode = NO;
        }
        
        request.isLocationEnquiryAllowed = NO;
        //request.paramsDictionary = [NSDictionary dictionaryWithObject:@"c_mopub" forKey:@"tp"];
        _adBannerView.imAdRequest = request;
        [_adBannerView loadIMAdRequest:request];
        
	}
    else{
        GHLogWarn(@"App Inmobi key null..");
    }
}

- (void)adViewDidFinishRequest:(IMAdView *)bannerView
{
	[self.adView setAdContentView:bannerView];
	[self.adView adapterDidFinishLoadingAd:self shouldTrackImpression:YES];
}

- (void)adView:(IMAdView *)bannerView
didFailRequestWithError:(IMAdError *)error
{
	[self.adView adapter:self didFailToLoadAdWithError:nil];
}

- (void)adViewWillPresentScreen:(IMAdView *)bannerView
{
	[self.adView userActionWillBeginForAdapter:self];
}

- (void)adViewDidDismissScreen:(IMAdView *)bannerView
{
	[self.adView userActionDidEndForAdapter:self];
}

- (void)adViewWillLeaveApplication:(IMAdView *)bannerView
{
	[self.adView userWillLeaveApplicationFromAdapter:self];
}

@end
