//
//  BaseView.h
//  eManual
//
//  Created by  on 11-12-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BASEVIEW_ANIMATION_DURATION 0.2f

@interface BaseView : UIView

-(void)show;
-(IBAction)dismiss;

+(id)loadFromBundle;

@property (nonatomic, readonly, getter = getSuperView) UIView* superView;
@property (nonatomic, assign) BOOL touchToDismiss;

@end
