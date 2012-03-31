//
//  BRBaseController.m
//  BreezyReader2
//
//  Created by 金 津 on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BRBaseController.h"
#import "NSObject+Notifications.h"

@interface BRBaseController ()

-(void)setupBackgroundView:(UIView*)backgroundView;

@end

@implementation BRBaseController

@synthesize backgroundView = _backgroundView;

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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - private methods

-(void)setupBackgroundView:(UIView *)backgroundView{
    [self.view addSubview:backgroundView];
    [self.view sendSubviewToBack:backgroundView];
}

@end
