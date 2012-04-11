//
//  BRADManager.h
//  BreezyReader2
//
//  Created by Jin Jin on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHAdViewDelegate.h"

#define NOTIFICATION_ADLOADED @"NOTIFICATION_ADLOADED"

@interface BRADManager : NSObject<GHAdViewDelegate>

+(id)sharedManager;

-(GHAdView*)adView;

@end
