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

@class BRFeedConfigViewController;

@protocol BRFeedConfigBase<NSObject>

@optional
-(UIView*)sectionView;

@end

@interface BRFeedConfigBase : NSObject<BRFeedConfigBase>

@property (nonatomic, retain) GRSubscription* subscription;

@property (nonatomic, assign) BRFeedConfigViewController* containerController;

-(NSString*)sectionTitle;
-(NSInteger)numberOfRowsInSection;
-(id)tableView:(UITableView*)tableView cellForRow:(NSInteger)index;
-(CGFloat)heightOfRowAtIndex:(NSInteger)index;
-(CGFloat)heightForHeader;

-(void)didSelectRowAtIndex:(NSInteger)index;
-(void)subscriptionChanged:(GRSubscription*)newSub;

@end
