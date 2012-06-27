//
//  JJAdView.m
//  BreezyReader2
//
//  Created by 津 金 on 12-6-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJAdView.h"

@interface JJAdView()

@property (nonatomic, assign) CGSize adSize;
@property (nonatomic, retain) id adView;

@end

@implementation JJAdView

@synthesize adSize = _adSize;
@synthesize delegate = _delegate;
@synthesize adView = _adView;
@synthesize adMobPublisherID = _adMobPublisherID;

static NSString* admobPublisherID = @"a14f851c3ba444f";

-(void)dealloc{
    self.adMobPublisherID = nil;
    self.adView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithSize:(CGSize)adSize{
    CGRect frame = CGRectZero;
    frame.size.width = adSize.width;
    frame.size.height = adSize.height;
    
    self.adSize = adSize;
    
    self = [super initWithFrame:frame];
    
    if (self){
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)loadAd{
    if ([self.delegate shouldLoadiAd]){
        //load iAd
        [self loadiAd];
    }else{
        //load admob
        [self loadAdmob];
    }
}

-(void)resumeAdRequest{
    if ([self.adView isKindOfClass:[ADBannerView class]]){
//        [(ADBannerView*)self.adView 
    }else{
        
    }
}

-(void)stopAdRequest{
    if ([self.adView isKindOfClass:[ADBannerView class]]){
        
    }else{
        
    }
}

-(void)loadiAd{
    [self.adView removeFromSuperview];
    ADBannerView* bannerView = [[[ADBannerView alloc] initWithFrame:self.bounds] autorelease];
    bannerView.delegate = self;
    [self addSubview:bannerView];
    self.adView = bannerView;
}

-(void)loadAdmob{
    [self.adView removeFromSuperview];
    GADBannerView* bannerView = [[[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner] autorelease];
    bannerView.delegate = self;
    bannerView.adUnitID = admobPublisherID;
    bannerView.rootViewController = [self.delegate viewControllerForPresentingModalView];
    GADRequest* request = [GADRequest request];
    CLLocation* location = [self.delegate locationInfo];
    if (location){
        [request setLocationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude accuracy:location.horizontalAccuracy];
    }
    [bannerView loadRequest:request];
    [self addSubview:bannerView];
    self.adView = bannerView;
}

#pragma mark - iAd banner view delegate
-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    //show ad
    DebugLog(@"iad load success");
    [self.delegate adViewDidLoadAd:self];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    DebugLog(@"iad load failed: %@", [error localizedDescription]);
    [self loadAdmob];
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
    return YES;
}

#pragma mark - admob banner view delegate
// Sent when an ad request loaded an ad.  This is a good opportunity to add this
// view to the hierarchy if it has not yet been added.  If the ad was received
// as a part of the server-side auto refreshing, you can examine the
// hasAutoRefreshed property of the view.
- (void)adViewDidReceiveAd:(GADBannerView *)view{
    DebugLog(@"admob load success");
    [self.delegate adViewDidLoadAd:self];
}

// Sent when an ad request failed.  Normally this is because no network
// connection was available or no ads were available (i.e. no fill).  If the
// error was received as a part of the server-side auto refreshing, you can
// examine the hasAutoRefreshed property of the view.
- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error{
    DebugLog(@"admob load failed");
    [self loadiAd];
}

@end
