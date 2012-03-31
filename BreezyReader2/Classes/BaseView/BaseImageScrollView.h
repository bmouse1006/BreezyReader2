//
//  BaseImageView.h
//  eManual
//
//  Created by  on 12-2-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseView.h"
#import "ImageScrollView.h"

@interface BaseImageScrollView : BaseView <UIScrollViewDelegate>

@property (nonatomic, retain) IBOutlet ImageScrollView* scrollView;

-(void)setImage:(UIImage*)image;

@end
