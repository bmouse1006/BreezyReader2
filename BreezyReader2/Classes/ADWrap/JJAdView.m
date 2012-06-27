//
//  JJAdView.m
//  BreezyReader2
//
//  Created by 津 金 on 12-6-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJAdView.h"

@interface JJAdView()

@property (nonatomic, assign) CGSize adSize;

@end

@implementation JJAdView

@synthesize adSize = _adSize;
@synthesize delegate = _delegate;

@synthesize adMobPublisherID = _adMobPublisherID;

-(void)dealloc{
    self.adMobPublisherID = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithSize:(CGSize)adSize{
    CGRect frame = CGRectZero;
    frame.size.width = adSize.width;
    frame.size.height = adSize.height;
    
    self.adSize = adSize;
    
    self = [super initWithFrame:frame];
    
    if (self){
        
    }
    
    return self;
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
