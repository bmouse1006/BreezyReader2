//
//  BaseImageView.m
//  eManual
//
//  Created by  on 12-2-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseImageScrollView.h"
#import <QuartzCore/QuartzCore.h>

@interface BaseImageScrollView ()

-(void)addGestureSupport;

@end

@implementation BaseImageScrollView

@synthesize scrollView = _scrollView;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self addGestureSupport];
    }
    
    return self;
}

-(void)dealloc{
    self.scrollView = nil;
    [super dealloc];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self addGestureSupport];
}

-(void)addGestureSupport{
    UITapGestureRecognizer* doubleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)] autorelease];
    doubleTap.numberOfTapsRequired = 2;
    UITapGestureRecognizer* singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)] autorelease];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    singleTap.numberOfTapsRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTap];
    [self.scrollView addGestureRecognizer:singleTap];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

-(void)doubleTapAction:(UITapGestureRecognizer*)tap{
    DebugLog(@"double tap happened", nil);
    if (tap.state == UIGestureRecognizerStateEnded){
        //handle double tap
        CGFloat scale = self.scrollView.zoomScale;
        CGFloat minscale = self.scrollView.minimumZoomScale;
        [self.scrollView setZoomScale:(scale == minscale)?minscale*2:minscale animated:YES];
        
    }
}

-(void)singleTapAction:(UITapGestureRecognizer*)tap{
    DebugLog(@"single tap happened", nil);
    if (tap.state == UIGestureRecognizerStateEnded){
        [UIApplication sharedApplication].statusBarHidden = NO;
        [self dismiss];
    }
}

-(void)setImage:(UIImage *)image{
    [self.scrollView setImage:image];
}

@end
