//
//  BaseAlertView.m
//  eManual
//
//  Created by  on 11-12-31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseAlertView.h"
#import <QuartzCore/QuartzCore.h>

#define BASEALERTVIEW_TITLELABEL_OFFSET 20.0f

@implementation BaseAlertView

@synthesize contentView = _contentView;
@synthesize titleLabel = _titleLabel;
@synthesize message = _message;

-(void)awakeFromNib{
    [super awakeFromNib];
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.cornerRadius = 8.0f;
}

-(void)setMessage:(NSString *)message{
    if (_message != message){
        [_message release];
        _message = [message copy];
        self.titleLabel.text = message;
    }
}

-(UIView*)getSuperView{
    return [[UIApplication sharedApplication].windows lastObject];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)show{
    [super show];
    CGRect frame = self.contentView.frame;
    frame.origin.y += BASEALERTVIEW_TITLELABEL_OFFSET;
    [self.contentView setFrame:frame];
    frame.origin.y -= BASEALERTVIEW_TITLELABEL_OFFSET;
    [UIView animateWithDuration:BASEVIEW_ANIMATION_DURATION animations:^{
        [self.contentView setFrame:frame];
    }];
    [[NSRunLoop mainRunLoop] addTimer:[NSTimer timerWithTimeInterval:2.0f target:self selector:@selector(dismiss) userInfo:nil repeats:NO] forMode:NSDefaultRunLoopMode];
}

-(void)dismiss{
    CGRect frame = self.contentView.frame;
    frame.origin.y -= BASEALERTVIEW_TITLELABEL_OFFSET;
    [UIView animateWithDuration:BASEVIEW_ANIMATION_DURATION animations:^{
        [self.contentView setFrame:frame];
    }];
    [super dismiss];
}

@end
