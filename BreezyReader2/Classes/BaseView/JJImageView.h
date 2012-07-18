//
//  JJImageView.h
//  BreezyReader2
//
//  Created by 金 津 on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@class JJImageView;

@protocol JJImageViewDelegate <NSObject>

-(void)imageDidFinishLoading:(JJImageView*)imageView;
-(void)imageDidStartLoading:(JJImageView*)imageView;
-(void)imageDidFailLoading:(JJImageView*)imageView;

@end

@interface JJImageView : UIImageView <ASIHTTPRequestDelegate>

@property (nonatomic, strong) NSURL* imageURL;
@property (nonatomic, strong) UIImage* defaultImage;
@property (nonatomic, unsafe_unretained) id<JJImageViewDelegate> delegate;

@property (nonatomic, assign) UIViewContentMode defautImageMode;

@property (nonatomic, assign) ASICacheStoragePolicy storagePolicy;

@end
