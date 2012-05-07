//
//  BRFeedConfigViewController.h
//  BreezyReader2
//
//  Created by 金 津 on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRSubscription.h"
#import "JJLabel.h"
#import "BRFeedConfigBase.h"
#import "BRSettingBaseController.h"

@interface BRFeedConfigViewController : BRSettingBaseController<UIAlertViewDelegate>

@property (nonatomic, retain) GRSubscription* subscription;

-(void)showSubscription:(GRSubscription*)subscription;
-(void)showAddNewTagView;
-(void)addNewTag:(NSString*)newLabel;;
-(void)addTag:(NSString*)tagID removeTag:(NSString*)tagID;
-(void)unsubscribeButtonClicked;
-(void)subscribeButtonClicked;
-(void)renameButtonClicked;

@end
