//
//  JJActiveView.m
//  RotateTest
//
//  Created by Jin Jin on 12-4-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJActiveView.h"

@implementation JJActiveView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createAnimationImages];
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self createAnimationImages];
}

-(void)createAnimationImages{
    NSString* imageBaseName = @"spinny-black-small-";
    NSMutableArray* images = [NSMutableArray array];
    for (int i = 1; i<= 16; i++){
        NSString* imageName = [imageBaseName stringByAppendingFormat:@"%d", i];
        UIImage* image = [UIImage imageNamed:imageName];
        [images addObject:image];
    }
    self.animationImages = images;
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
