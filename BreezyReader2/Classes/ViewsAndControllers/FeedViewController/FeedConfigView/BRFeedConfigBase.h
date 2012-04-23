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

@protocol BRFeedConfigBase<NSObject>

@optional
-(UIView*)sectionView;

@end

@interface BRFeedConfigBase : UIViewController<BRFeedConfigBase>

@property (nonatomic, retain) GRSubscription* subscription;

-(NSString*)sectionTitle;
-(NSInteger)numberOfRowsInSection;
-(id)cellForRow:(NSInteger)index;
-(CGFloat)heightOfRowAtIndex:(NSInteger)index;
-(CGFloat)heightForHeader;

@end
