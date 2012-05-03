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

@property (nonatomic, retain) IBOutlet UIView* container;

@property (nonatomic, retain) IBOutlet JJLabel* titleLabel;
@property (nonatomic, retain) IBOutlet UILabel* snipetLabel;
@property (nonatomic, retain) IBOutlet UILabel* subscriberLabel;
@property (nonatomic, retain) IBOutlet UILabel* velocityLabel;

@property (nonatomic, retain) IBOutlet UIView* topSeperateLine;

-(void)setItem:(id)item;

@end
