
#import <UIKit/UIKit.h>
#import "IMAdDelegate.h"
#import "IMAdRequest.h"
/*
 * IMAdView.h
 * @description The view that displays banner ads.  A minimum implementation to get an ad
 * from within a UIViewController class is:
 * Place an ad at the top of the screen of an iPhone/iPod Touch.
 * Create and setup the ad view. Below is the example to instantiate an IMAdView with ad unit slot "9"
 IMAdView *adView = [[IMAdView alloc] initWithFrame:CGRectMake(0, 00, 320, 48) imAppId:@"xxxxxxxxxxxxxxxxxxxx" imAdUnit:IM_UNIT_320x48 rootViewController:self];
 * Make your UIViewController adhere to IMAdDelegate protocol to receive state change notifications.
 adView.delegate = self;
 * Place the ad view onto the screen.
 [self.view addSubview:adView];
 * Release the adView in the dealloc method of your UIViewController
 - (void)dealloc {
 adView.delegate = nil;
 [adView release]; adView = nil;
 [super dealloc];
 }
 * @author: InMobi
 * Copyright 2011 InMobi Technologies Pvt. Ltd.. All rights reserved.
 */
@interface IMAdView : UIView 

#define REFRESH_INTERVAL_OFF -1

enum AnimationTypes {
    /**
     * No animation in between of an ad refresh.
     */
    kIMAnimationOff,
    /**
     * Ad refresh will perform a UIViewAnimationTransitionCurlUp.
     */
    kIMAnimationCurlUp ,
    /**
     * Ad refresh will perform a UIViewAnimationTransitionCurlDown.
     */
    kIMAnimationCurlDown,
    /**
     * Ad refresh will perform a UIViewAnimationTransitionFlipFromLeft.
     */
    kIMAnimationFlipFromLeft,
    /**
     * Ad refresh will perform a UIViewAnimationTransitionFlipFromRight.
     */
    kIMAnimationFlipFromRight
    
};
typedef enum AnimationTypes AnimationType;

#pragma mark Ad Units

/**
 * Default ad size for iPhone and iPod Touch.
 * The ad size equivalent to this slot is CGSizeMake(320, 48)
 */
#define IM_UNIT_320x48        9
/**
 * Medium Rectangle size for the iPad (especially in a UISplitView's left pane).
 * The ad size equivalent to this slot is CGSizeMake(300, 250)
 */
#define IM_UNIT_300x250       10
/**
 * Leaderboard size for the iPad.
 * The ad size equivalent to this slot is CGSizeMake(728,90)
 */
#define IM_UNIT_728x90        11
/**
 * Full Banner size for the iPad (especially in a UIPopoverController or in UIModalPresentationFormSheet).
 * The ad size equivalent to this slot is CGSizeMake(468x60)
 */
#define IM_UNIT_468x60        12
/**
 * Skyscraper size, designed for iPad's screen size.
 * The ad size equivalent to this slot is CGSizeMake(120x600)
 */
#define IM_UNIT_120x600       13
/**
 * Default ad size for iPhone and iPod Touch.
 * The ad size equivalent to this slot is CGSizeMake(320, 48)
 */
#define IM_UNIT_320x50        15 

#pragma required properties

/**
 * You can obtain your AppId under Publisher section by logging into inmobi.com . 
 * @description Must be not-null.
 */
@property ( nonatomic, copy) NSString *imAppId;
/**
 * Required reference to the current root view controller. For example the root
 * view controller in navigation-based application would be the UINavigationController.
 * @description must be not-null.
 */
@property ( nonatomic, assign) UIViewController *rootViewController;

/**
 * The ad-unit slot to request for the specific banner size.
 * @description Defaults to IM_AD_SIZE_320x50. Please see above for supported banner sizes and their slots.
 */
@property ( nonatomic, assign) int imAdUnit;

#pragma optional properties

/**
 * Specify a time period (seconds) for this view to refresh ads.
 * To disable auto refreshing, set this value to REFRESH_INTERVAL_OFF.
 * @description The default value is 60 seconds. Minimum refresh interval should be 20 seconds.
 * @throws InvalidArgumentException if interval is set to less than minimum refresh interval.
 */
@property ( nonatomic, assign) int refreshInterval;

/**
 * Optional delegate object that receives state change notifications from this view.
 * Typically this is a UIViewController instance.
 * Set the delegate property of this view to nil in the dealloc method of your UIViewController.
 - (void)dealloc {
 imAdView.delegate = nil;
 [imadView release]; imAdView = nil;
 [super dealloc];
 *   }
 */
@property ( nonatomic, assign) IBOutlet id<IMAdDelegate> delegate;

/**
 * Specify animationtype to be performed when this view will refresh.
 * @description Default value is kIMAnimationCurlUp
 */
@property (nonatomic, assign) AnimationType animationType;

/**
 * Specify additional parameters for targeted advertising.
 * You may call loadIMAdRequest method for this view to load the request.
 * Optionally you can specify a request object by calling loadIMAdRequest: method for this view.
 * @note see IMAdRequest class for more details
 */
@property ( nonatomic, retain) IMAdRequest *imAdRequest;

/**
 * @description Use this constructor to obtain an instance of IMAdView.
 * @param frame The CGRect bounds for this view, typically according to the adunit slot requested.
 * @param _imAppId The publisher's app-id as obtained from inmobi.
 * @param _imAdUnit The adunit slot, to request the specific banner size.
 * @param _viewController The rootviewcontroller for this view.
 */
- (id)initWithFrame:(CGRect)frame imAppId:(NSString *)_imAppId imAdUnit:(int)_imAdUnit rootViewController:(UIViewController *)_viewController;

/**
 * @description Call this method to refresh this view.
 * @param _request The IMAdRequest object for requesting additional parameters.
 */
- (void)loadIMAdRequest:(IMAdRequest *)_request;

/**
 * @description Call this method to refresh this view.
 * This method will call loadIMAdRequest: with the imAdRequest object specified for this view.
 */
- (void)loadIMAdRequest;



/**
 * Use this method to specify the text color for the ad.
 * The color value must be of the format @"#RRGGBB"
 * @param _color the RGB value of the color.
 * @note This method will be valid only for a "text ad". For other ads, the value will be ignored. 
 */
- (void)setAdTextColor:(NSString *)_color;

/**
 * Use this method to specify background color for the ad.
 * The color value must be of the format @"#RRGGBB"
 * @param _color the RGB value of the color.
 * @note This method will be valid only for a "text ad". For other ads, the value will be ignored. 
 */
- (void)setAdBackgroundColor:(NSString *)_bgcolor;

/**
 * Use this method to specify background color with a linear gradient.
 * The color value must be of the format @"#RRGGBB"
 * @param _topcolor the top RGB value for the gradient.
 * @param _bottomcolor the bottom RGB value for the gradient.
 * @note This method will be valid only for a "text ad". For other ads, the value will be ignored.
 */
- (void)setAdBackgroundGradientWithTopColor:(NSString *)_topcolor bottomColor:(NSString *)_bottomcolor;
/**
 * optional
 * Use this method to assign a custom reference tag at the time of making an Ad Request to the InMobi Ad Server.
 * [inmobiAdView setRefTag:@"top ad on navigation bar" forKey:@"ref-tag"];
 * @param value the value for this ref-tag
 * @param key the key for this ref-tag
 * @note Maximum character limit for ref-tag is 50.
 */
- (void)setRefTag:(NSString *)value forKey:(NSString *)key;

@end
