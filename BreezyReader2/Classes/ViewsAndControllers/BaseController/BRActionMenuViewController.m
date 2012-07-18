//
//  BRActionMenuViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRActionMenuViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface BRActionMenuViewController ()

@end

@implementation BRActionMenuViewController

@synthesize menu = _menu;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.clipsToBounds = YES;
    self.menu.layer.masksToBounds = YES;
    self.menu.layer.cornerRadius = 8.0f;
    self.menu.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.menu.layer.borderWidth = 2.0f;
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.menu = nil;
    // Release any retained subviews of the main view.
}

-(void)dismiss{
    self.menu.userInteractionEnabled = NO;
    CGRect frame = self.menu.frame;
    frame.origin.y = self.view.frame.size.height;
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.menu.frame = frame;
    } completion:^(BOOL finished){
        self.menu.userInteractionEnabled = YES;
        self.view.hidden = YES;
    }];
}

-(void)showMenuInPosition:(CGPoint)position anchorPoint:(CGPoint)anchor{
    
    [self.view.superview bringSubviewToFront:self.view];
    
    self.view.hidden = NO;
    CGRect frame = self.view.frame;
    frame.origin.x = position.x-frame.size.width*anchor.x;
    frame.origin.y = position.y-frame.size.height*anchor.y;
    self.view.frame = frame;
    
    frame = self.menu.frame;
    frame.origin.y = self.view.frame.size.height;
    self.menu.frame = frame;
    frame.origin.y = 0;
    self.menu.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.menu.frame = frame;
    } completion:^(BOOL finished){
        self.menu.userInteractionEnabled = YES;
    }];
}


@end
