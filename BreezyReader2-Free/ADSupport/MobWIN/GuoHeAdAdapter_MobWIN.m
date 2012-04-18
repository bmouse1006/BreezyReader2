//
//  GuoHeAdAdapter_MobWIN.m
//  GuoHeProiOSDev
//
//  Created by Mike Peng on 26/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GuoHeAdAdapter_MobWIN.h"
#import "GHAdView.h"

@implementation GuoHeAdAdapter_MobWIN
@synthesize adBannerView = _adBannerView;

- (void)dealloc
{
    [_adBannerView removeGestureRecognizer:_nonListenerGR];
    [_nonListenerGR release];
    [_adRequest release];
	[_adBannerView  release];
	[super dealloc];
}

- (void)getAdWithParams:(NSString *)keyInfo adSize:(CGSize)adsize
{
    MobWinBannerSizeIdentifier adSizeIndetifier = MobWINBannerSizeIdentifier320x50;

    if (adsize.width==320&&adsize.height==50) {
        adSizeIndetifier = MobWINBannerSizeIdentifier320x50;
    }else if (adsize.width==300&&adsize.height==250) {
        adSizeIndetifier = MobWINBannerSizeIdentifier300x250;
    }else if (adsize.width==468&&adsize.height==60) {
        adSizeIndetifier = MobWINBannerSizeIdentifier468x60;
    }else if (adsize.width==728&&adsize.height==90) {
        adSizeIndetifier = MobWINBannerSizeIdentifier728x90;
    }else{
        GHLogWarn(@"App MobWIN size wrong..");
        adSizeIndetifier = MobWINBannerSizeIdentifierUnknow;
    }
    
    NSArray *keyArray = [keyInfo componentsSeparatedByString:@"|;|"];
	if ([keyArray count]>0) {
        MobWinBannerView *adBanner = [[MobWinBannerView alloc] initMobWinBannerSizeIdentifier:adSizeIndetifier]; 
        adBanner.rootViewController = [self.adView.delegate viewControllerForPresentingModalView];
        adBanner.adRefreshInterval = 200;
        self.adBannerView = adBanner;
        [adBanner release];
        
        
        if (_adBannerView) {
            //---------- begin: add codes for non-listener ad network track click data
            if (_nonListenerGR==nil) {
                _nonListenerGR = [[UITapGestureRecognizer alloc] initWithTarget:self.adView action:@selector(nonListenerNetworkAdClicked)];
            }        
            [_nonListenerGR setDelegate:self];
            [_nonListenerGR setNumberOfTapsRequired:1];
            [_nonListenerGR setNumberOfTouchesRequired:1];
            [_nonListenerGR setCancelsTouchesInView:NO];
            
            [_adBannerView addGestureRecognizer:_nonListenerGR];
            //----------- end
            
            _adRequest = [[MobWinAdRequest alloc] init];
            _adRequest.adUnitID = [[keyArray objectAtIndex:0] retain];
            
            [_adBannerView startRequest:_adRequest];
            
            [self.adView setAdContentView:_adBannerView];
            [self.adView adapterDidFinishLoadingAd:self shouldTrackImpression:YES];
            
        } else {
            [self.adView adapter:self didFailToLoadAdWithError:nil];
        }
        
    }
    else{
        GHLogWarn(@"App MobWIN key null..");
    }
}

- (void)adapterWillDealloc
{
    [_adBannerView stopRequest];
}

///ad click gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([[touch.view class] isSubclassOfClass:[UIButton class]]) {
        [self.adView nonListenerNetworkAdClicked];
    }
    return  YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return  YES;
}


@end
