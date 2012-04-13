//
//  JJImageScrollController.h
//  BreezyReader2
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJPageScrollView.h"
#import "JJLabel.h"

@interface JJImageScrollController : UIViewController<JJPageScrollViewDelegate, JJPageScrollViewDataSource>

@property (nonatomic, retain) JJPageScrollView* scrollView; 
@property (nonatomic, retain) NSArray* imageList;
@property (nonatomic, assign) NSInteger index;

-(void)setImageList:(NSArray*)imageList startIndex:(NSInteger)index;

-(UIImage*)imageAtIndex:(NSInteger)index;

@end
