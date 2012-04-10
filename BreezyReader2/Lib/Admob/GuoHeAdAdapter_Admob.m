//
//  GuoHeAdAdapter_Admob.m
//  GuoHeSDKTest
//
//  Created by Daniel on 10-12-15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GuoHeAdAdapter_Admob.h"
#import "GHAdView.h"
#import "CJSONDeserializer.h"

@implementation GuoHeAdAdapter_Admob
@synthesize adBannerView = _adBannerView;

- (void)dealloc
{
    [_adBannerView removeGestureRecognizer:_nonListenerGR];
    [_nonListenerGR release];
	_adBannerView.delegate = nil;
	[_adBannerView release];
	[super dealloc];
}

- (void)getAdWithParams:(NSString *)keyInfo adSize:(CGSize)adsize
{
	NSArray *keyArray = [keyInfo componentsSeparatedByString:@"|"];
	if ([keyArray count]>0) {
        //_adBannerView.frame = CGRectMake(, , ,);
        CGRect frame = CGRectMake(self.adView.adParentView.frame.origin.x, self.adView.adParentView.frame.origin.y, adsize.width, adsize.height);
		self.adBannerView = [[GADBannerView alloc] initWithFrame:frame];
		_adBannerView.delegate = self;
		_adBannerView.adUnitID = [keyArray objectAtIndex:0];
        _adBannerView.rootViewController = [self.adView.delegate viewControllerForPresentingModalView];
        GADRequest *request = [GADRequest request];
        [_adBannerView loadRequest:request];
        
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

	}
    else{
        _adBannerView.adUnitID = nil;
        GHLogWarn(@"App Admob key null..");
    }
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
	[self.adView setAdContentView:bannerView];
	[self.adView adapterDidFinishLoadingAd:self shouldTrackImpression:YES];
}

- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error
{
	[self.adView adapter:self didFailToLoadAdWithError:nil];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView
{
	[self.adView userWillLeaveApplicationFromAdapter:self];
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
