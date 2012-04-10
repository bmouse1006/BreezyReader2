//
//  GHBaseAdapter.h
//  GuoHeProiOSDev
//
//  Created by Daniel Chen on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class GHAdView;

@interface GHBaseAdapter : NSObject {
    GHAdView *_adView;
}

@property (nonatomic, readonly) GHAdView *adView;


/*
 * Creates an adapter with a reference to an GHAdView.
 */
- (id)initWithAdView:(GHAdView *)adView;

/*
 * Sets the adapter's delegate to nil.
 */
- (void)unregisterDelegate;

/*
 * -getAdWithParams: needs to be implemented by adapter subclasses that want to load native ads.
 */
- (void)getAdWithParams:(NSString *)keyInfo adSize:(CGSize)adsize;

/*
 * Your subclass should implement this method if your native ads vary depending on orientation.
 */
- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation;

@end
