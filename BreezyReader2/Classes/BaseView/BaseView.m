//
//  BaseView.m
//  eManual
//
//  Created by  on 11-12-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseView.h"

@implementation BaseView

@synthesize superView = _superView;
@synthesize touchToDismiss = _touchToDismiss;
@synthesize jjViewDelegate = _jjViewDelegate;

-(void)dealloc{
    self.jjViewDelegate = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.touchToDismiss = YES;
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.touchToDismiss = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.nextResponder touchesBegan:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.nextResponder touchesCancelled:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.touchToDismiss){
        [self dismiss];
    }
    [self.nextResponder touchesEnded:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.nextResponder touchesMoved:touches withEvent:event];
}

-(UIView*)getSuperView{
    return [[UIApplication sharedApplication].windows objectAtIndex:0];
}

-(void)dismiss{
    __block typeof(self) blockSelf = self;
    if ([self.jjViewDelegate respondsToSelector:@selector(viewWillDismiss:)]){
        [self.jjViewDelegate viewWillDismiss:self];
    }
    [UIView animateWithDuration:BASEVIEW_ANIMATION_DURATION animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished){
        if (finished == YES){
            [self removeFromSuperview];
            DebugLog(@"view removed", nil);
            if ([blockSelf.jjViewDelegate respondsToSelector:@selector(viewDidDismiss:)]){
                [blockSelf.jjViewDelegate viewDidDismiss:blockSelf];
            }
        }
    }];
}

-(void)show{

    UIView* sv = [self getSuperView];
    CGRect bounds = sv.bounds;
    [self setFrame:bounds];
    [sv addSubview:self];
    self.alpha = 0;
    [sv bringSubviewToFront:self];
    __block typeof(self) blockSelf = self;
    if ([self.jjViewDelegate respondsToSelector:@selector(viewWillShow:)]){
        [self.jjViewDelegate viewWillShow:self];
    }
    [UIView animateWithDuration:BASEVIEW_ANIMATION_DURATION animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished){
        if (finished){
            if ([blockSelf.jjViewDelegate respondsToSelector:@selector(viewDidShow:)]){
                [blockSelf.jjViewDelegate viewDidShow:blockSelf];
            }
        }
    }];
}

+(id)loadFromBundle{
    id obj = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] objectAtIndex:0];
    return obj;
}

@end
