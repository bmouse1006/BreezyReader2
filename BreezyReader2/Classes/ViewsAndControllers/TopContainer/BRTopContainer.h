//
//  BRTopContainer.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    JJViewTransitionPop,
    JJViewTransitionZoomIn,
    JJViewTransitionZoomOut,
    JJViewTransitionNone
} JJViewTransitionType;

@interface BRTopContainer : UIViewController

-(void)addToTop:(UIViewController*)controller animated:(BOOL)animated;

-(void)popViewController:(BOOL)animated;
-(void)boomOutViewController:(UIViewController*)viewController fromView:(UIView*)view;
-(void)boomInTopViewController;

-(void)slideInViewController:(UIViewController*)viewController;
-(void)slideOutViewController;

-(void)replaceTopByController:(UIViewController*)viewController animated:(BOOL)animated;

-(UIViewController*)topController;

@end
