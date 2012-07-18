//
//  BRFeedConfigBaseCell.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedConfigBaseCell.h"

@implementation BRFeedConfigBaseCell

@synthesize topBlack = _topBlack, topWhite = _topWhite;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        [self setupCell];
    }
    
    return self;
}


-(void)awakeFromNib{
    [super awakeFromNib];
    [self setupCell];
}

-(void)setupCell{
//    self.topBlack = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    self.topWhite = [[UIView alloc] initWithFrame:CGRectZero];
//    self.topBlack.backgroundColor = [UIColor darkGrayColor];
    self.topWhite.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
//    [self.contentView addSubview:self.topBlack];
    [self.contentView addSubview:self.topWhite];
    UIView* backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.backgroundView = backgroundView;
    
    UIView* selectedBackgroundView =  [[UIView alloc] initWithFrame:self.bounds];
    selectedBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    self.selectedBackgroundView = selectedBackgroundView;
    
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.font = [UIFont boldSystemFontOfSize:13];
    
    self.detailTextLabel.textColor = [UIColor lightGrayColor];
    self.detailTextLabel.font = [UIFont boldSystemFontOfSize:12];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat inset = 5.0f;
//    CGRect frame = CGRectMake(inset, 0, width-inset*2, 0.5);
//    self.topBlack.frame = frame;
    CGRect frame = CGRectMake(inset, 0, width-inset*2, 0.5);
    self.topWhite.frame = frame;
}

@end
