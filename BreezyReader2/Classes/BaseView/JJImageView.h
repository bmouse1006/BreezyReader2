//
//  JJImageView.h
//  BreezyReader2
//
//  Created by 金 津 on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"

@class JJImageView;

@protocol JJImageViewDelegate <NSObject>

-(void)imageDidFinishLoading:(JJImageView*)imageView;
-(void)imageDidStartLoading:(JJImageView*)imageView;
-(void)imageDidFailLoading:(JJImageView*)imageView;

@end

@interface JJImageView : UIImageView <ASIHTTPRequestDelegate>

@property (nonatomic, retain) NSURL* imageURL;
@property (nonatomic, retain) UIImage* defaultImage;
@property (nonatomic, assign) id<JJImageViewDelegate> delegate;

@property (nonatomic, assign) UIViewContentMode defautImageMode;

@end
