//
//  InfinityScrollContainer.m
//  BreezyReader2
//
//  Created by 金 津 on 12-1-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "InfinityScrollContainer.h"

@implementation InfinityScrollContainer

@synthesize leftContainer = _leftContainer;
@synthesize rightContainer = _rightContainer;
@synthesize view = _view;
@synthesize index = _index;

-(id)initWithContainerFrame:(CGRect)frame{
    self = [super init];
    if (self){
        self.view = [[[UIView alloc] initWithFrame:frame] autorelease];
        self.view.backgroundColor = [UIColor clearColor];
        self.leftContainer = nil;
        self.rightContainer = nil;
        self.index = -1;
    }
    
    return self;
}

-(void)dealloc{
    self.view = nil;
    [super dealloc];
}

-(void)addViewToContainer:(UIView*)view{

    NSArray* subviews = [self.view subviews];
    for (UIView* subview in subviews){
        if (subview == view){
            return;
        }
        [subview removeFromSuperview];
    }
    [self.view addSubview:view];
    view.center = self.view.center;
}

@end
