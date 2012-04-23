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

-(void)dealloc{
    self.addNewButton = nil;
    [super dealloc];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self.addNewButton setTitle:NSLocalizedString(@"title_addnewlabel", nil) forState:UIControlStateNormal];
    [self.addNewButton setTitle:NSLocalizedString(@"title_addnewlabel", nil) forState:UIControlStateSelected];
    [self.contentView addSubview:self.addNewButton];
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
    CGRect frame = self.addNewButton.frame;
    frame.size.width = self.bounds.size.width;
    self.addNewButton.frame = frame;
}

@end
