//
//  BRFeedConfigSectionView.h
//  BreezyReader2
//
//  Created by 金 津 on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJLabel.h"

@interface BRFeedConfigSectionView : UIView

@property (nonatomic, retain) IBOutlet JJLabel* titleLabel;

@property (nonatomic, retain) IBOutlet UIView* topWhite;
@property (nonatomic, retain) IBOutlet UIView* topBlack;

@end
