//
//  BRBottomToolBar.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRBottomToolBar.h"

@implementation BRBottomToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupBackground];
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self setupBackground];
}

-(void)setupBackground{
    UIView* black = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.5)] autorelease];
    black.backgroundColor = [UIColor lightGrayColor];
    UIView* white = [[[UIView alloc] initWithFrame:CGRectMake(0, 0.5, 320, 0.5)] autorelease];
    white.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:black];
    [self addSubview:white];
    
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_background_pattern"]];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(ctx);
//    
//    [super drawRect:rect];
//    
//    CGContextMoveToPoint(ctx, 0, 0);
//    CGContextAddLineToPoint(ctx, 320, 0);
//    CGContextSetLineWidth(ctx, 0.5);
//    [[UIColor blackColor] setFill];
//    CGContextFillPath(ctx);
//    
//    CGContextMoveToPoint(ctx, 0, 0.5);
//    CGContextAddLineToPoint(ctx, 320, 0.5);
//    CGContextSetLineWidth(ctx, 0.5);
//    [[UIColor whiteColor] setFill];
//    CGContextFillPath(ctx);
//    
//    CGContextRestoreGState(ctx);
//}


-(void)layoutSubviews{
    [super layoutSubviews];
    
}

@end
