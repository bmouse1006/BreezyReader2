//
//  BaseAlertView.h
//  eManual
//
//  Created by  on 11-12-31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseView.h"

@interface BaseAlertView : BaseView

@property (nonatomic, retain) IBOutlet UIView* contentView;
@property (nonatomic, retain) IBOutlet UILabel* titleLabel;

@property (nonatomic, copy, setter = setMessage:) NSString* message;

@end
