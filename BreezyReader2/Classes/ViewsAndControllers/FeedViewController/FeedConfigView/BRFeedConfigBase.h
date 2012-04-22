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

@interface BRFeedConfigBase : UIViewController

@property (nonatomic, retain) GRSubscription* subscription;

-(NSString*)sectionTitle;
-(UIView*)sectionView;
-(NSInteger)numberOfRowsInSection;
-(id)cellForRow:(NSInteger)index;
-(CGFloat)heightOfRowAtIndex:(NSInteger)index;
-(CGFloat)heightForHeader;

@end
