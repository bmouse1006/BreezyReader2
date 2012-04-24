//
//  BRFeedLabelsViewController.h
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRFeedConfigBase.h"
#import "JJLabel.h"

@interface BRFeedLabelsViewController : BRFeedConfigBase

@property (nonatomic, retain) IBOutlet JJLabel* titleLabel;

@property (nonatomic, retain) IBOutlet UIView* topWhite;
@property (nonatomic, retain) IBOutlet UIView* topBlack;

@end
