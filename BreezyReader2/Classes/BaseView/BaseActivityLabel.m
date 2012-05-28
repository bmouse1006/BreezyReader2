//
//  BaseActivityLabel.m
//  MeetingPlatform
//
//  Created by  on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseActivityLabel.h"
#import <QuartzCore/QuartzCore.h>

@implementation BaseActivityLabel

@synthesize contentView = _contentView, label = _label;
@synthesize doneImage = _doneImage, activityView = _activityView, failedImage = _failedImage;
@dynamic message;

-(void)awakeFromNib{
    [super awakeFromNib];
    self.contentView.layer.cornerRadius = 8.0f;
    self.touchToDismiss = NO;
}

-(void)dealloc{
    self.contentView = nil;
    self.label = nil;
    self.doneImage = nil;
    self.activityView = nil;
    self.failedImage = nil;
    [super dealloc];
}

-(NSString*)message{
    return self.label.text;
}

-(void)setMessage:(NSString *)message{
   self.label.text = message; 
}

-(void)dismissAfterDelay:(NSTimeInterval)delay{
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:delay];
}

-(void)setFinished:(BOOL)finished{
    if (finished){
        self.doneImage.hidden = NO;
    }else{
        self.failedImage.hidden = NO;
    }
    self.activityView.hidden = YES;
    [self dismissAfterDelay:1.0f];
}

@end
