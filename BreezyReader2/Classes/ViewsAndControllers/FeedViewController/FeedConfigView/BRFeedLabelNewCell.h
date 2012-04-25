//
//  BRFeedLabelNewCell.h
//  BreezyReader2
//
//  Created by 金 津 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJLabel.h"
#import "BRFeedConfigBaseCell.h"

@interface BRFeedLabelNewCell : BRFeedConfigBaseCell

@property (nonatomic, retain) IBOutlet UIButton* addNewButton;
@property (nonatomic, retain) IBOutlet JJLabel* addNewLabel;

@end
