//
//  UIViewController+transition.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+addition.h"

@implementation UIViewController (addition)

-(void)removeGradientImage:(UIView*)view{
    for (UIView* subview in view.subviews){
        if ([subview isKindOfClass:[UIImageView class]]){
            subview.hidden = YES;
        }
        [self removeGradientImage:subview];
    }
}

@end
