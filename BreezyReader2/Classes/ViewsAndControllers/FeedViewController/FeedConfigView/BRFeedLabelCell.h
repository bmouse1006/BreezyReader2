//
//  BRFeedLabelCell.h
//  BreezyReader2
//
//  Created by 金 津 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRFeedConfigBaseCell.h"

@interface BRFeedLabelCell : BRFeedConfigBaseCell

@property (nonatomic, copy) NSString* title;
@property (nonatomic, assign) BOOL isChecked;

@property (nonatomic, strong) IBOutlet UIImageView* checkmark;

@end
