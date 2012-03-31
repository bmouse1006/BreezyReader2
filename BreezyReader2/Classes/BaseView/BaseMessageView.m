//
//  BaseMessageView.m
//  eManual
//
//  Created by  on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "BaseMessageView.h"

@implementation BaseMessageView

@synthesize message = _message;
@synthesize container = _container;
@synthesize textView = _textView;

-(void)awakeFromNib{
    [super awakeFromNib];
    
    self.container.layer.borderWidth = 1.0f;
    self.container.layer.borderColor = [UIColor grayColor].CGColor;
    self.container.layer.cornerRadius = 8.0f;
    self.container.layer.masksToBounds = YES;
}

-(void)dealloc{
    self.message = nil;
    self.container = nil;
    self.textView = nil;
    [super dealloc];
}

-(void)setMessage:(NSString *)message{
    if (_message != message){
        [_message release];
        _message = [message copy];
        
        self.textView.text = message;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self dismiss];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

-(void)show{
    [super show];
    self.container.transform = CGAffineTransformMakeScale(1, 0.05);
    [UIView animateWithDuration:BASEVIEW_ANIMATION_DURATION 
                          delay:0 
                        options:UIViewAnimationOptionCurveEaseOut 
                     animations:^{
                        self.container.transform = CGAffineTransformIdentity; 
                     } 
                     completion:NULL]; 
}

-(void)dismiss{
    [UIView animateWithDuration:BASEVIEW_ANIMATION_DURATION 
                          delay:0 
                        options:UIViewAnimationOptionCurveEaseIn 
                     animations:^{
                         self.container.transform = CGAffineTransformMakeScale(1, 0.05); 
                     } 
                     completion:NULL]; 

    [super dismiss];
}

@end
