//
//  InfinityScrollViewController.h
//  BreezyReader2
//
//  Created by 金 津 on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfinityScrollView.h"

@interface InfinityScrollViewController : UIViewController <InfinityScrollViewDataSource>

@property (nonatomic, retain) IBOutlet InfinityScrollView* scrollView;
@property (nonatomic, retain) NSArray* contentControllers;

@end
