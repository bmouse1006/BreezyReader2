//
//  BRFeedTableViewCell.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRItem.h"
#import "JJImageView.h"
#import "JJLabel.h"

@interface BRFeedTableViewCell : UITableViewCell

@property (nonatomic, retain) GRItem* item;
@property (nonatomic, retain) IBOutlet JJImageView* urlImageView;

@property (nonatomic, retain) IBOutlet UIView* bottomSeperateLine;
@property (nonatomic, retain) IBOutlet JJLabel* titleLabel;
@property (nonatomic, retain) IBOutlet JJLabel* previewLabel;
@property (nonatomic, retain) IBOutlet JJLabel* timeLabel;
@property (nonatomic, retain) IBOutlet JJLabel* authorLabel;

@property (nonatomic, retain) IBOutlet UIView* container;

@end
