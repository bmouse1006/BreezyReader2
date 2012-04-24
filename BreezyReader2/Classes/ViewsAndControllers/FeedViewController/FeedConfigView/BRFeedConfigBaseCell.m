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

-(void)dealloc{
    self.topBlack = nil;
    self.topWhite = nil;
    [super dealloc];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self setupCell];
//    UIView* selectedView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
//    selectedView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
//    self.selectedBackgroundView = selectedView;
}

-(void)setupCell{
    self.topBlack = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    self.topWhite = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    self.topBlack.backgroundColor = [UIColor darkGrayColor];
    self.topWhite.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:self.topBlack];
    [self addSubview:self.topWhite];
    UIView* backgroundView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
    backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.backgroundView = backgroundView;
    
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.font = [UIFont boldSystemFontOfSize:13];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat inset = 5.0f;
    CGRect frame = CGRectMake(inset, 0, width-inset*2, 0.5);
    self.topBlack.frame = frame;
    frame = CGRectMake(inset, 0.5, width-inset*2, 0.5);
    self.topWhite.frame = frame;
}

@end
