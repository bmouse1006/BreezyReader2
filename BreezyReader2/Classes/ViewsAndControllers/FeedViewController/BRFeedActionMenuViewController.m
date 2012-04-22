//
//  BRFeedActionMenuViewController.m
//  BreezyReader2
//
//  Created by Jin Jin on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedActionMenuViewController.h"
#import "BRViewControllerNotification.h"
#import <QuartzCore/QuartzCore.h>

@interface BRFeedActionMenuViewController ()

@end

@implementation BRFeedActionMenuViewController

@synthesize menu = _menu;

-(void)dealloc{
    self.menu = nil;
    [super dealloc];
}

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
    self.menu.layer.masksToBounds = YES;
    self.menu.layer.cornerRadius = 4.0f;
    // Do any additional setup after loading the view from its nib.
//    self.view.autoresizingMask = UIViewAuto;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidLayoutSubviews{
    CGRect frame = self.menu.frame;
    frame = self.view.bounds;
    self.menu.frame = frame;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MENUACTION_DISAPPEAR object:self.menu];
}

-(void)showMenuInPosition:(CGPoint)position anchorPoint:(CGPoint)anchor{
    
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

-(IBAction)showUnreadOnlyButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MENUACTION_UNREADONLY object:sender];
    [self dismiss];
}

-(IBAction)showAllArticlesButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICAITON_MENUACTION_ALLARTICLES object:sender];
    [self dismiss];
}

-(IBAction)markAllAsReadButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MENUACTION_MARKALLASREAD object:sender];
    [self dismiss];
}

@end
