//
//  BRFeedLabelNewCell.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedLabelNewCell.h"

@implementation BRFeedLabelNewCell

@synthesize addNewButton = _addNewButton;
@synthesize addNewLabel = _addNewLabel;


-(void)awakeFromNib{
    [super awakeFromNib];
    [self.contentView addSubview:self.addNewLabel];
    self.addNewLabel.text = NSLocalizedString(@"title_addnewlabel", nil);
    self.addNewLabel.font = [UIFont boldSystemFontOfSize:13];
    self.addNewLabel.backgroundColor = [UIColor clearColor];
    self.addNewLabel.textAlignment = UITextAlignmentCenter;
    self.addNewLabel.verticalAlignment = JJTextVerticalAlignmentMiddle;
    self.addNewLabel.textColor = [UIColor whiteColor];
    
    [self.addNewButton setTitle:NSLocalizedString(@"title_addnewlabel", nil) forState:UIControlStateNormal];
    [self.addNewButton setTitle:NSLocalizedString(@"title_addnewlabel", nil) forState:UIControlStateSelected];
//    [self.contentView addSubview:self.addNewButton];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.addNewButton.frame = self.bounds;
    self.addNewLabel.frame = self.bounds;
}

@end
