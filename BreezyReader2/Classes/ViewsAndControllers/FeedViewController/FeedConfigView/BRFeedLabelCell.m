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
@synthesize checkmark = _checkmark;

-(void)dealloc{
    self.title = nil;
    self.checkmark = nil;
    [super dealloc];
}

-(void)awakeFromNib{
    [super awakeFromNib];
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
