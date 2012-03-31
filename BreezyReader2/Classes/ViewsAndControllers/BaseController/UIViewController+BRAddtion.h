//
//  UIViewController+BRAddtion.h
//  BreezyReader2
//
//  Created by 金 津 on 12-2-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRTopContainer.h"

@interface UIViewController (BRAddtion)

-(id)initWithTheNibOfSameName;
-(BRTopContainer*)topContainer;

@end
