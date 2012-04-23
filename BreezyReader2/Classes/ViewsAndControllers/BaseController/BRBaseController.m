//
//  BRBaseController.m
//  BreezyReader2
//
//  Created by 金 津 on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BRBaseController.h"
#import "NSObject+Notifications.h"
#import <QuartzCore/QuartzCore.h>

#define kAnimationTransitionDuration 0.2f

@interface BRBaseController (){
    UIView* _sideShadow;
    UIControl* _hideButton;
}

-(void)setupBackgroundView:(UIView*)backgroundView;

@end

@implementation BRBaseController

@synthesize backgroundView = _backgroundView;
@synthesize mainContainer = _mainContainer;
@synthesize secondaryView = _secondaryView;
@synthesize secondaryViewIsShown = _secondaryViewIsShown;

static CGFloat distance = 0.0f;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self registerNotifications];
    }
    return self;
}

-(void)dealloc{
    self.backgroundView = nil;
    self.mainContainer = nil;
    self.secondaryView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - operate content views
-(void)switchContentViewsToViews:(NSArray *)views animated:(BOOL)animated{
    CGFloat duration = 0.8f;
    if (animated == NO){
        duration = 0.0f;
    }
    NSMutableArray* contentViews = [NSMutableArray array];
    for (UIView* view in self.view.subviews){
        if (view != self.backgroundView){
            [contentViews addObject:view];
        }
    }
    for (UIView* view in views){
        view.alpha = 0.0f;
        [self.view addSubview:view];
    }
    [UIView animateWithDuration:duration animations:^{
        [contentViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            UIView* view = obj;
            view.alpha = 0.0f;
        }];
         
        [views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            UIView* view = obj;
            view.alpha = 1.0f;
        }];

    } completion:^(BOOL finished){
        [contentViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBackgroundView:self.backgroundView];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.mainContainer = nil;
    self.secondaryView = nil;
    self.backgroundView = nil;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view.layer removeAllAnimations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - show/hide covered list menu
-(void)slideShowSecondaryView{
    
    distance = self.mainContainer.frame.size.width/4*3;
    
    //add shadow
    UIImageView* shadow = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 6, self.view.bounds.size.height)] autorelease];
    shadow.contentMode = UIViewContentModeScaleToFill;
    shadow.image = [UIImage imageNamed:@"right_shadow"];
    _sideShadow = shadow;
    [self.mainContainer addSubview:_sideShadow];
    CGRect frame = _sideShadow.frame;
    frame.origin.x = self.mainContainer.bounds.size.width;
    _sideShadow.frame = frame;
    //add hide button
    UIControl* hideButton = [[[UIControl alloc] initWithFrame:self.mainContainer.bounds] autorelease];
    [hideButton addTarget:self action:@selector(slideHideSecondaryView) forControlEvents:UIControlEventTouchUpInside];
    hideButton.backgroundColor = [UIColor clearColor];
    _hideButton = hideButton;
    [self.mainContainer addSubview:hideButton];
    
    [self.view insertSubview:self.secondaryView belowSubview:self.mainContainer];
    
    CAKeyframeAnimation* positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = kAnimationTransitionDuration*3;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint center = self.mainContainer.center;
    CGFloat dx = 10;
    CGPathMoveToPoint(path, NULL, center.x, center.y);
    CGPathAddLineToPoint(path, NULL, center.x-distance-dx*2, center.y);
    CGPathAddLineToPoint(path, NULL, center.x-distance+dx, center.y);
    CGPathAddLineToPoint(path, NULL, center.x-distance, center.y);
    positionAnimation.path = path;
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    CGPathRelease(path);
    positionAnimation.delegate = self;
    positionAnimation.removedOnCompletion = NO;
    
    [self.mainContainer.layer addAnimation:positionAnimation forKey:@"show"];
    
    self.mainContainer.center = CGPointMake(center.x-distance, center.y);
    
    _secondaryViewIsShown = YES;
}

-(void)slideHideSecondaryView{
    [UIView animateWithDuration:kAnimationTransitionDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.mainContainer.frame = self.view.bounds;
    }completion:^(BOOL finished){
        _secondaryViewIsShown = NO;
        [self.secondaryView removeFromSuperview];
        [_sideShadow removeFromSuperview];
        [_hideButton removeFromSuperview];
        _sideShadow = nil;
        _hideButton = nil;
    }];
}

- (void)animationDidStart:(CAAnimation *)anim{
//    self.mainContainer.hidden = YES;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag{
//    self.mainContainer.hidden = NO;
//    CGRect frame = self.mainContainer.frame;
//    frame.origin.x =  -distance;
//    self.mainContainer.frame = frame;
    [self.mainContainer bringSubviewToFront:_hideButton];
}

#pragma mark - private methods

-(void)setupBackgroundView:(UIView *)backgroundView{
    [self.view addSubview:backgroundView];
    [self.view sendSubviewToBack:backgroundView];
}

@end
