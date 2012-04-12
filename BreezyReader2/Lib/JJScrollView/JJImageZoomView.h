//
//  ImageScrollView.h
//  eManual
//
//  Created by  on 12-2-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJImageZoomView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, readonly) UIImage* loadedImage;

-(void)setImage:(UIImage*)image;
-(void)setImageURL:(NSString*)imageURL;

@end
