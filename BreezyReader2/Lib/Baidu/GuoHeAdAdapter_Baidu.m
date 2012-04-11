//
//  GuoHeAdAdapter_Baidu.m
//  GuoHeProiOSDev
//
//  Created by Wulin on 23/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GuoHeAdAdapter_Baidu.h"
#import "GHAdView.h"

@implementation GuoHeAdAdapter_Baidu
@synthesize theKey, theSpec;
@synthesize adBannerView = _adBannerView;

- (void)dealloc
{
    [_adBannerView removeGestureRecognizer:_nonListenerGR];
    [_nonListenerGR release];
    [_adBannerView release];
    [theKey release];
    [theSpec release];
	[super dealloc];
}

- (void)getAdWithParams:(NSString *)keyInfo adSize:(CGSize)adsize
{
	NSArray *keyArray = [keyInfo componentsSeparatedByString:@"|;|"];
	if ([keyArray count]>2) {
        self.theKey = [keyArray objectAtIndex:0]; 
        self.theSpec = [keyArray objectAtIndex:1];
        self.adBannerView = [BaiduMobAdView sharedAdViewWithDelegate:self];
        _adBannerView.frame = CGRectMake(0, 0, 320, 50);
        _adBannerView.AdType = [[keyArray objectAtIndex:2] intValue];

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
        self.theKey = nil;
        self.theSpec = nil;
        GHLogWarn(@"App Baidu key null..");
    }
}

- (NSString *)publisherId
{
    return self.theKey;
}

- (NSString*) appSpec
{
    return self.theSpec;
}

-(BOOL) enableLocation
{
    return NO;
}

-(int) displayInterval
{
    return 100;
}

-(void) willDisplayAd:(BaiduMobAdView*) adview
{
    [self.adView setAdContentView:adview];
	[self.adView adapterDidFinishLoadingAd:self shouldTrackImpression:YES];
}

-(void) failedDisplayAd:(BaiduMobFailReason) reason
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
