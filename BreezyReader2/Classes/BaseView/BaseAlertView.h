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

@property (nonatomic, strong) IBOutlet UIView* contentView;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, copy, setter = setMessage:) NSString* message;

@end
