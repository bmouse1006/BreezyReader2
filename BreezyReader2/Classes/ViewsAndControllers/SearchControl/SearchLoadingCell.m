//
//  SearchLoadingCell.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SearchLoadingCell.h"

@interface SearchLoadingCell ()

@property (nonatomic, strong) UILabel* label;

@end

@implementation SearchLoadingCell

@synthesize label = _label;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.label.backgroundColor = self.backgroundColor;
    self.label.font = [UIFont boldSystemFontOfSize:18];
    self.label.textColor = [UIColor grayColor];
    self.label.textAlignment = UITextAlignmentCenter;
    self.label.text = NSLocalizedString(@"msg_searching", nil);
    [self.contentView addSubview:self.label];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
