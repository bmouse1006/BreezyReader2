//
//  BaseActivityLabel.h
//  MeetingPlatform
//
//  Created by  on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseView.h"

@interface BaseActivityLabel : BaseView

@property (nonatomic, retain) IBOutlet UIView* contentView;
@property (nonatomic, retain) IBOutlet UILabel* label;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activityView;
@property (nonatomic, retain) IBOutlet UIImageView* doneImage;
@property (nonatomic, retain) NSString* message;

-(void)dismissAfterDelay:(NSTimeInterval)delay;

-(void)setFinished:(BOOL)finished;

@end
