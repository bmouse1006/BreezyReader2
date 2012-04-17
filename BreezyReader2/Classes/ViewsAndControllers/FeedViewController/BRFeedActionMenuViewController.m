//
//  BRFeedActionMenuViewController.m
//  BreezyReader2
//
//  Created by Jin Jin on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedActionMenuViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface BRFeedActionMenuViewController ()

@end

@implementation BRFeedActionMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.view.autoresizingMask = UIViewAuto;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dismiss{
    self.view.hidden = YES;
}

-(void)showMenuInPosition:(CGPoint)position anchorPoint:(CGPoint)anchor{
    
    self.view.hidden = NO;
    CGRect frame = self.view.frame;
    frame.origin.x = position.x-frame.size.width;
    frame.origin.y = position.y-frame.size.height;
    self.view.frame = frame;
    CALayer* layer = self.view.layer;
    layer.anchorPoint = anchor;
    
    CAKeyframeAnimation* boundsOvershootAnimation =[CAKeyframeAnimation animationWithKeyPath:@"transform"];
    CATransform3D startingScale =CATransform3DScale(layer.transform,0,0,0);
    CATransform3D overshootScale =CATransform3DScale(layer.transform,1.1,1.1,1.0);
    CATransform3D undershootScale =CATransform3DScale(layer.transform,0.95,0.95,1.0);
    CATransform3D endingScale = layer.transform;
    NSArray*boundsValues =[NSArray arrayWithObjects:[NSValue valueWithCATransform3D:startingScale],
                           [NSValue valueWithCATransform3D:overshootScale],
                           [NSValue valueWithCATransform3D:undershootScale],
                           [NSValue valueWithCATransform3D:endingScale],nil];
    [boundsOvershootAnimation setValues:boundsValues];
    NSArray*times =[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],
                    [NSNumber numberWithFloat:0.8f],
                    [NSNumber numberWithFloat:0.9f],
                    [NSNumber numberWithFloat:1.0f],nil];
    [boundsOvershootAnimation setKeyTimes:times];
    NSArray*timingFunctions =[NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                              [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                              [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                              nil];
    [boundsOvershootAnimation setTimingFunctions:timingFunctions];
    boundsOvershootAnimation.fillMode = kCAFillModeForwards;
    boundsOvershootAnimation.removedOnCompletion = NO;
    
    CAKeyframeAnimation* alpha = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    
    alpha.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],
                      [NSNumber numberWithFloat:1.0f], nil];  
    alpha.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],
                    [NSNumber numberWithFloat:1.0f], nil];  
    
    CAAnimationGroup* group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:boundsOvershootAnimation, alpha, nil];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = YES;
    
    [layer addAnimation:group forKey:@"showmenu"];
}

@end
