//
//  BRFeedDetailCell.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedDetailCell.h"

@implementation BRFeedDetailCell

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

-(void)setItem:(id)item{
    self.textLabel.text = [item objectForKey:@"title"];
    self.detailTextLabel.text = [item objectForKey:@"contentSnippet"];
}

@end
