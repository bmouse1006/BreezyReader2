//
//  BRBaseController.h
//  BreezyReader2
//
//  Created by 金 津 on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+BRAddtion.h"
#import "BRTopContainer.h"
#import "BRActionMenuViewController.h"
#import "BRViewControllerNotification.h"

@interface BRBaseController : UIViewController

@property (nonatomic, retain) IBOutlet UIView* backgroundView;
@property (nonatomic, retain) IBOutlet UIView* mainContainer; 
@property (nonatomic, retain) IBOutlet BRActionMenuViewController* actionMenuController;

@property (nonatomic, retain) IBOutlet UIView* secondaryView;

@property (nonatomic, readonly) BOOL secondaryViewIsShown;

-(void)switchContentViewsToViews:(NSArray*)views animated:(BOOL)animated;

-(void)slideShowSecondaryViewWithCompletionBlock:(void(^)())block;
-(void)slideHideSecondaryViewWithCompletionBlock:(void(^)())block;

-(void)secondaryViewWillShow;
-(void)secondaryViewDidShow;
-(void)secondaryViewWillHide;
-(void)secondaryViewDidHide;
@end
