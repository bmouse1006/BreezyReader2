//
//  BRFeedDetailCell.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJLabel.h"

@interface BRFeedDetailCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIView* container;

@property (nonatomic, strong) IBOutlet JJLabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* snipetLabel;
@property (nonatomic, strong) IBOutlet UILabel* subscriberLabel;
@property (nonatomic, strong) IBOutlet UILabel* velocityLabel;

@property (nonatomic, strong) IBOutlet UIView* topSeperateLine;

-(void)setItem:(id)item;

@end
