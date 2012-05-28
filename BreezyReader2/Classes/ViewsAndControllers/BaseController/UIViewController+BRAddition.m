//
//  UIViewController+BRNSString+Addition.m
//  BreezyReader2
//
//  Created by 金 津 on 12-2-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+BRAddition.h"

@implementation UIViewController (BRAddition)

-(id)initWithTheNibOfSameName{
    return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

-(BRTopContainer*)topContainer{
    if ([self isKindOfClass:[BRTopContainer class]]){
        return (BRTopContainer*)self;
    }
    if ([self.parentViewController isKindOfClass:[BRTopContainer class]]){
        return (BRTopContainer*)self.parentViewController;
    }else{
        return [self.parentViewController topContainer];
    }
}

@end
