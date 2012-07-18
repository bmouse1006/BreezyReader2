//
//  BRFeedConfigSectionView.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedConfigSectionView.h"

@implementation BRFeedConfigSectionView

@synthesize titleLabel = _titleLabel, subTitleLabel = _subTitleLabel;
@synthesize topBlack = _topBlack, topWhite = _topWhite;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createSubviews];
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self createSubviews];
}

-(void)createSubviews{
    self.titleLabel = [[JJLabel alloc] initWithFrame:CGRectZero];
    [self setupLabel:self.titleLabel];
    self.subTitleLabel = [[JJLabel alloc] initWithFrame:CGRectZero];
    [self setupLabel:self.subTitleLabel];
    self.subTitleLabel.textColor = [UIColor whiteColor];
    self.subTitleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.subTitleLabel.textAlignment = UITextAlignmentRight;
//    self.topBlack = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    self.topWhite = [[UIView alloc] initWithFrame:CGRectZero];
//    self.topBlack.backgroundColor = [UIColor darkGrayColor];
    self.topWhite.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4f];;
    [self addSubview:self.topWhite];
//    [self addSubview:self.topBlack];
    [self addSubview:self.titleLabel];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    CGRect frame = CGRectMake(0, 0, width, 0.5);
//    self.topBlack.frame = frame;
//    frame = CGRectMake(0, 0.5, width, 0.5);
    self.topWhite.frame = frame;
    self.titleLabel.frame = self.bounds;
    [self sendSubviewToBack:self.titleLabel];
}

-(void)setupLabel:(JJLabel*)label{
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.verticalAlignment = JJTextVerticalAlignmentMiddle;
    label.shadowBlur = 3;
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(1, 1);
    label.shadowEnable = NO;
    [label setContentEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
}

@end
