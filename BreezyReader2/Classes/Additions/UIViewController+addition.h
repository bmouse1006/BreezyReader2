//
//  UIViewController+transition.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CGPointCenterOfRect(rect) CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2)

@interface UIViewController (addition)

-(void)removeGradientImage:(UIView*)view;

@end
