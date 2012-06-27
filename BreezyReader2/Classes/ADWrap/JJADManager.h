//
//  JJADManager.h
//  BreezyReader2
//
//  Created by Jin Jin on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define NOTIFICATION_ADLOADED @"NOTIFICATION_ADLOADED"

#ifdef FREEVERSION

#import "JJAdView.h"

@interface JJADManager : NSObject<JJAdViewDelegate, CLLocationManagerDelegate>

#else

@interface JJADManager : NSObject<CLLocationManagerDelegate>

#endif

+(id)sharedManager;
+(void)checkCurrentCountry;

-(UIView*)adView;

@end
