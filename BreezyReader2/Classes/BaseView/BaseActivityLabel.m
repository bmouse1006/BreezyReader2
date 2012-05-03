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
@dynamic message;

-(void)awakeFromNib{
    [super awakeFromNib];
    self.contentView.layer.cornerRadius = 8.0f;
    self.touchToDismiss = NO;
}

-(void)dealloc{
    self.contentView = nil;
    self.label = nil;
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


@end
