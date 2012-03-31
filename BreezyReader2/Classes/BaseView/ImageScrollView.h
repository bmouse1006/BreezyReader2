//
//  ImageScrollView.h
//  eManual
//
//  Created by  on 12-2-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, retain) IBOutlet UIImageView* imageView;

-(void)setImage:(UIImage*)image;

@end
