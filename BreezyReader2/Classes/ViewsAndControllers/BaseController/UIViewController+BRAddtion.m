//
//  UIViewController+BRAddtion.m
//  BreezyReader2
//
//  Created by 金 津 on 12-2-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+BRAddtion.h"

@implementation UIViewController (BRAddtion)

-(id)initWithTheNibOfSameName{
    return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

-(BRTopContainer*)topContainer{
    if ([self.parentViewController isKindOfClass:[BRTopContainer class]]){
        return (BRTopContainer*)self.parentViewController;
    }else{
        return [self.parentViewController topContainer];
    }
}

@end
