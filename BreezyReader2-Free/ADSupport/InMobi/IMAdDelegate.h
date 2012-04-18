


#import <Foundation/Foundation.h>
@class IMAdView;
@class IMAdError;

/*
 * InMobiAdDelegate.h
 * @description Defines the InMobiAdDelegate protocol.
 * @author: InMobi
 * Copyright 2011 InMobi Technologies Pvt. Ltd.. All rights reserved.
 */
@protocol IMAdDelegate <NSObject>
 
@optional

#pragma mark Ad Request Lifecycle Notifications
 
/**
 * Sent when an ad request loaded an ad.  This is a good opportunity to add this
 * view to the hierarchy if it has not yet been added.
 * @param view The IMAdView which finished loading the ad request.
 */

- (void)adViewDidFinishRequest:(IMAdView *)adView;

/**
 * Sent when an ad request failed.  Normally this is because no network
 * connection was available or no ads were available (i.e. no fill).  If the
 * error was received as a part of the server-side auto refreshing, you can
 * examine the hasAutoRefreshed property of the view.
 * @param view The IMAdView which failed to load the ad request.
 * @param error The error that occurred during loading.
 */

- (void)adView:(IMAdView *)view
didFailRequestWithError:(IMAdError *)error;


#pragma mark Click-Time Lifecycle Notifications

/**
 * Sent just before the adview will present a full screen view to the user.
 * Use this opportunity to stop animations and save the state of your application.
 * @param adView The adview responsible for presenting the screen.
 */
- (void)adViewWillPresentScreen:(IMAdView *)adView;

/**
 * Sent just before dismissing a full screen view.
 * @param adView The adview responsible for dismissing the screen.
 */
- (void)adViewWillDismissScreen:(IMAdView *)adView;

/**
 * Sent just after dismissing a full screen view.  Use this opportunity to
 * restart anything you may have stopped as part of adViewWillPresentScreen:.
 * @param adView The adview responsible for dismissing the screen.
 */
- (void)adViewDidDismissScreen:(IMAdView *)adView;

/**
 * Sent just before the application will background or terminate because the
 * user clicked on an ad that will launch another application (such as the App
 * Store).
 * @param adView The adview responsible for launching another application.
 * @note The normal UIApplicationDelegate methods, like
 * applicationDidEnterBackground:, will be called immediately after this.
 */

- (void)adViewWillLeaveApplication:(IMAdView *)adView;

@end

