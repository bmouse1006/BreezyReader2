//
//  BRFeedLabelCell.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedLabelCell.h"

@implementation BRFeedLabelCell

@synthesize title = _title;
@synthesize isChecked = _isChecked;
@synthesize button = _button;
@synthesize checkmark = _checkmark;

-(void)dealloc{
    self.title = nil;
    self.button = nil;
    self.checkmark = nil;
    [super dealloc];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self.contentView addSubview:self.button];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect frame = self.button.frame;
    frame.size.width = self.bounds.size.width;
    self.button.frame = frame;
    
    self.textLabel.text = self.title;
    if (self.isChecked){
//        self.accessoryType = UITableViewCellAccessoryCheckmark;
        self.accessoryView = self.checkmark;
        self.textLabel.textColor = [UIColor whiteColor];
    }else{
//        self.accessoryType = UITableViewCellAccessoryNone;
        self.accessoryView = nil;
        self.textLabel.textColor = [UIColor lightGrayColor];
    }
}

@end
