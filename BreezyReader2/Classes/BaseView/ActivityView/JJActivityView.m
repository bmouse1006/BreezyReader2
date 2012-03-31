//
//  JJActivityView.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJActivityView.h"
#import <QuartzCore/QuartzCore.h>

@interface JJActivityView()

@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) NSTimer* timer;

-(void)createImageView;

@end

@implementation JJActivityView

@synthesize imageView = _imageView;
@synthesize timer = _timer;

-(void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
    self.imageView = nil;
    [super dealloc];
}

-(id)init{
    return [self initWithFrame:CGRectMake(0, 0, 32, 32)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createImageView];
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self createImageView];
}

-(void)createImageView{
    self.backgroundColor = [UIColor clearColor];
    self.imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fresh_page"]] autorelease];
//    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.imageView];
    self.imageView.frame = self.bounds;
}

-(void)stopAnimating{
    [self.layer removeAllAnimations];
    [self.timer invalidate];
    self.timer = nil;
}

-(void)startAnimating{
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(rotate) userInfo:nil repeats:YES];
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:M_PI],[NSNumber numberWithFloat:-0.01], nil];
    rotateAnimation.duration =2;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:0],
                                [NSNumber numberWithFloat:0.5], 
                                [NSNumber numberWithFloat:1], nil];
    rotateAnimation.repeatCount = HUGE_VALF;
    rotateAnimation.fillMode = kCAFillModeForwards;
    rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.imageView.layer addAnimation:rotateAnimation forKey:@"rotate"];
}

-(void)rotate{
    self.imageView.transform = CGAffineTransformRotate(self.imageView.transform,(M_PI/180.0)*3);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
