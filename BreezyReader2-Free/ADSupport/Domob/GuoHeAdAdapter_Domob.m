//
//  GuoHeAdAdapter_Domob.m
//  TestGuoHeAd1
//
//  Created by Daniel on 11-5-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "GuoHeAdAdapter_Domob.h"
#import "GHAdView.h"

@implementation GuoHeAdAdapter_Domob

@synthesize publishID = _publishID;
@synthesize testOrNot = _testOrNot;
@synthesize doMobView = _doMobView;

- (void)getAdWithParams:(NSString *)keyInfo adSize:(CGSize)adsize
{
    CGSize doMobsize;
    if (adsize.width==320&&adsize.height==50) {
        doMobsize = DOMOB_SIZE_320x48;
    }else if (adsize.width==300&&adsize.height==250) {
        doMobsize = DOMOB_SIZE_320x270;
    }else if (adsize.width==468&&adsize.height==60) {
        doMobsize = DOMOB_SIZE_488x80;
    }else if (adsize.width==728&&adsize.height==90) {
        doMobsize = DOMOB_SIZE_748x110;
    }
    
	NSArray *keyArray = [keyInfo componentsSeparatedByString:@"|;|"];
	if ([keyArray count]>1) {
        self.publishID = [keyArray objectAtIndex:0];
        self.testOrNot = [keyArray objectAtIndex:1];
        self.doMobView = [DoMobView requestDoMobViewWithSize:doMobsize WithDelegate:self];

        //---------- begin: add codes for non-listener ad network track click data
        if (_nonListenerGR==nil) {
            _nonListenerGR = [[UITapGestureRecognizer alloc] initWithTarget:self.adView action:@selector(nonListenerNetworkAdClicked)];
        }        
        _nonListenerGR.delegate = self;
        [_nonListenerGR setNumberOfTapsRequired:1];
        [_nonListenerGR setNumberOfTouchesRequired:1];
        [_nonListenerGR setCancelsTouchesInView:NO];
        [self.doMobView addGestureRecognizer:_nonListenerGR];
        //----------- end
    }
    else{
        GHLogWarn(@"App Domob key null..");
    }
}

- (void)dealloc {
    [_doMobView removeGestureRecognizer:_nonListenerGR];
    [_nonListenerGR release];
    _doMobView.doMobDelegate = nil;
    [_doMobView release];
    [_publishID release];
    [_testOrNot release];
	[super dealloc];
}

- (NSString *)domobPublisherIdForAd:(DoMobView *)doMobView{
    GHLogDebug(@"Domob key:%@",_publishID);
    return self.publishID;
}

- (UIViewController *)domobCurrentRootViewControllerForAd:(DoMobView *)doMobView{
    return [self.adView.delegate viewControllerForPresentingModalView];
}

- (BOOL)domobIsTestingMode{
    BOOL debugOrNot = NO;
    if ([_testOrNot compare:@"true"]==NSOrderedSame) {
        debugOrNot = YES;
    }
    return debugOrNot;
}

- (NSString *)domobKeywords{
   
	return nil;
}


// 当第一次成功接收到广告后通知应用程序。开发者可以在此时将广告视图添加到当前的View中。该回调只会调用一次。
- (void)domobDidReceiveAdRequest:(DoMobView *)doMobView{
    [self.adView setAdContentView:_doMobView];
	[self.adView adapterDidFinishLoadingAd:self shouldTrackImpression:YES];
}

// 当后续成功接收广告后通知应用程序。
- (void)domobDidReceiveRefreshedAd:(DoMobView *)doMobView{
    
}

// 当第一次接收广告失败后通知应用程序。该回调只会调用一次。
- (void)domobDidFailToReceiveAdRequest:(DoMobView *)doMobView{
    [self.adView adapter:self didFailToLoadAdWithError:nil];
}

// 当后续的接收广告失败后通知应用程序。
- (void)domobDidFailToReceiveRefreshedAd:(DoMobView *)doMobView{
    
}

// 全屏显示广告之后，发送该通知。
- (void)domobDidPresentFullScreenModalFromAd:(DoMobView *)doMobView
{
    
}

// 退出全屏广告显示之前，发送该通知。开发者可以在此恢复应用程序的相关动画、时间敏感时间的交互等。
- (void)domobDidDismissFullScreenModalFromAd:(DoMobView *)doMobView
{
    
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
