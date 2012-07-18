//
//  BaseActivityLabel.h
//  MeetingPlatform
//
//  Created by  on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseView.h"

@interface BaseActivityLabel : BaseView

@property (nonatomic, strong) IBOutlet UIView* contentView;
@property (nonatomic, strong) IBOutlet UILabel* label;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView * activityView;
@property (nonatomic, strong) IBOutlet UIImageView* doneImage;
@property (nonatomic, strong) IBOutlet UIImageView* failedImage;
@property (nonatomic, strong) NSString* message;

-(void)dismissAfterDelay:(NSTimeInterval)delay;

-(void)setFinished:(BOOL)finished;

@end
