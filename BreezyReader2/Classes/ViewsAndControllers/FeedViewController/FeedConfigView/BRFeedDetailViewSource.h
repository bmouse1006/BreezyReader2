//
//  BRFeedDetailViewSource.h
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJLabel.h"
#import "BRFeedConfigBase.h"

@interface BRFeedDetailViewSource : BRFeedConfigBase

@property (nonatomic, strong) IBOutlet JJLabel* titleLabel;
@property (nonatomic, strong) IBOutlet JJLabel* urlLabel;
@property (nonatomic, strong) IBOutlet JJLabel* descLabel;
@property (nonatomic, strong) IBOutlet JJLabel* weeklyArticleCountLabel;
@property (nonatomic, strong) IBOutlet JJLabel* subscriberLabel;
@property (nonatomic, strong) IBOutlet JJLabel* lastUpdateLabel;

@property (nonatomic, strong) IBOutlet UIView* container;

@end
