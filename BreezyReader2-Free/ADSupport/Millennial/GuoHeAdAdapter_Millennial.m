//
//  GuoHeAdAdapter_Millennial.m
//  GuoHeProiOSDev
//
//  Created by Mike Peng on 19/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GuoHeAdAdapter_Millennial.h"
#import "GHAdView.h"

@implementation GuoHeAdAdapter_Millennial
@synthesize adBannerView = _adBannerView;

- (void)dealloc
{
    [_adBannerView removeGestureRecognizer:_nonListenerGR];
    [_nonListenerGR release];
	self.adBannerView.refreshTimerEnabled = NO;
    self.adBannerView.delegate = nil;
    self.adBannerView = nil;
    [self.adBannerView release];
	[super dealloc];
}

- (void)getAdWithParams:(NSString *)keyInfo adSize:(CGSize)adsize
{
	NSArray *keyArray = [keyInfo componentsSeparatedByString:@"|;|"];
	if ([keyArray count]>0) {
        MMAdView *mmadView = [[MMAdView adWithFrame:CGRectMake(0,0,320,50) 
                                             type:MMBannerAdTop 
                                             apid:[keyArray objectAtIndex:0] 
                                         delegate:self 
                                           loadAd:YES 
                                       startTimer:YES] retain];
        self.adBannerView = mmadView;
        [mmadView release];
        
        //---------- begin: add codes for non-listener ad network track click data
        if (_nonListenerGR==nil) {
            _nonListenerGR = [[UITapGestureRecognizer alloc] initWithTarget:self.adView action:@selector(nonListenerNetworkAdClicked)];
        }        
        _nonListenerGR.delegate = self;
        [_nonListenerGR setNumberOfTapsRequired:1];
        [_nonListenerGR setNumberOfTouchesRequired:1];
        [_nonListenerGR setCancelsTouchesInView:NO];
        [self.adBannerView addGestureRecognizer:_nonListenerGR];
        //----------- end

	}
    else{
        GHLogWarn(@"App Millennial key null..");
    }
}

#pragma mark -
#pragma mark MMAdViewDelegate

- (void)adRequestSucceeded:(MMAdView *)adView
{
	[self.adView setAdContentView:adView];
	[self.adView adapterDidFinishLoadingAd:self shouldTrackImpression:YES];
}

- (void)adRequestFailed:(MMAdView *)adView
{
	[self.adView adapter:self didFailToLoadAdWithError:nil];
}

- (void)applicationWillTerminateFromAd
{
	[self.adView userWillLeaveApplicationFromAdapter:self];
}

- (BOOL) accelerometerEnabled
{
    return NO;
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
