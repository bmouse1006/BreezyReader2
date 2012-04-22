//
//  BRFeedDetailViewController.h
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJLabel.h"
#import "BRFeedConfigBase.h"

@interface BRFeedDetailViewController : BRFeedConfigBase

@property (nonatomic, retain) IBOutlet JJLabel* titleLabel;
@property (nonatomic, retain) IBOutlet JJLabel* urlLabel;
@property (nonatomic, retain) IBOutlet JJLabel* descLabel;
@property (nonatomic, retain) IBOutlet JJLabel* weeklyArticleCountLabel;
@property (nonatomic, retain) IBOutlet JJLabel* subscriberLabel;
@property (nonatomic, retain) IBOutlet JJLabel* lastUpdateLabel;

@property (nonatomic, retain) IBOutlet UIView* container;

@end
