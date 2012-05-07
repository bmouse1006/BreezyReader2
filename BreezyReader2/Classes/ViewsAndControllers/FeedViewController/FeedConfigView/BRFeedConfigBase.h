//
//  BRFeedConfigBase.h
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRSubscription.h"
#import "BRViewControllerNotification.h"
#import "BRSettingDataSource.h"

@class BRFeedConfigViewController;

@interface BRFeedConfigBase : NSObject<BRSettingDataSource>

@property (nonatomic, retain) GRSubscription* subscription;

@property (nonatomic, assign) BRFeedConfigViewController* tableController;

-(void)subscriptionChanged:(GRSubscription*)newSub;
-(void)viewDidDisappear;

@end
