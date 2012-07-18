//
//  BRBaseController.h
//  BreezyReader2
//
//  Created by 金 津 on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+BRAddition.h"
#import "BRTopContainer.h"
#import "BRActionMenuViewController.h"
#import "BRViewControllerNotification.h"

@interface BRBaseController : UIViewController

@property (nonatomic, strong) IBOutlet UIView* backgroundView;
@property (nonatomic, strong) IBOutlet UIView* mainContainer; 
@property (nonatomic, strong) IBOutlet BRActionMenuViewController* actionMenuController;

@property (nonatomic, strong) IBOutlet UIView* secondaryView;

@property (nonatomic, readonly) BOOL secondaryViewIsShown;

-(void)switchContentViewsToViews:(NSArray*)views animated:(BOOL)animated;

-(void)slideShowSecondaryViewWithCompletionBlock:(void(^)())block;
-(void)slideHideSecondaryViewWithCompletionBlock:(void(^)())block;

-(void)secondaryViewWillShow;
-(void)secondaryViewDidShow;
-(void)secondaryViewWillHide;
-(void)secondaryViewDidHide;
@end
