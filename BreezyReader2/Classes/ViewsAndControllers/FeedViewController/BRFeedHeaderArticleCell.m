//
//  BRFeedHeaderArticleCell.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedHeaderArticleCell.h"
#import "BRImagePreviewCache.h"
#import "NSString+Addition.h"

@interface BRFeedHeaderArticleCell (){
    BOOL _hasImage;
}

@end

@implementation BRFeedHeaderArticleCell

@synthesize bottomShadow = _bottomShadow;
@synthesize starButton = _starButton, unstarButton = _unstarButton;
@synthesize glowButton = _glowButton;

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

-(void)awakeFromNib{
//    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.shadowEnable = YES;
    self.titleLabel.shadowBlur = 2;
    self.titleLabel.shadowColor = [UIColor blackColor];
    self.titleLabel.shadowOffset = CGSizeMake(1, 1);
    
    self.authorLabel.font = [UIFont boldSystemFontOfSize:10];
    self.authorLabel.textColor = [UIColor whiteColor];
    self.authorLabel.verticalAlignment = JJTextVerticalAlignmentBottom;
    self.authorLabel.shadowEnable = YES;
    self.authorLabel.shadowBlur = 2;
    self.authorLabel.shadowColor = [UIColor blackColor];
    self.authorLabel.shadowOffset = CGSizeMake(1, 1);
    
    self.timeLabel.font = [UIFont boldSystemFontOfSize:10];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.verticalAlignment = JJTextVerticalAlignmentBottom;
    self.timeLabel.shadowEnable = YES;
    self.timeLabel.shadowBlur = 2;
    self.timeLabel.shadowColor = [UIColor blackColor];
    self.timeLabel.shadowOffset = CGSizeMake(1, 1);
    
    UIEdgeInsets inset = UIEdgeInsetsMake(3, 7, 3, 7);
    
    [self.titleLabel setContentEdgeInsets:inset];
    [self.authorLabel setContentEdgeInsets:inset];
    [self.timeLabel setContentEdgeInsets:inset];
    
    self.bottomShadow.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.container addSubview:self.titleLabel];
    [self.container addSubview:self.timeLabel];
    [self.container addSubview:self.authorLabel];
    [self.container addSubview:self.buttonContainer];
    [self.container addSubview:self.glowButton];
    self.glowButton.hidden = YES;
    
    [self.contentView addSubview:self.container];
}

-(void)layoutSubviews{
    static double titleLabelHeight = 60.0f;
    static double authLabelHeight = 18.0f;
    
    CGFloat width = self.frame.size.width;
    self.authorLabel.frame = CGRectMake(0, 6, width, authLabelHeight);
//    self.authorLabel.frame = CGRectMake(0, authLabelHeight+6, width, authLabelHeight);
    CGRect frame = self.buttonContainer.frame;
    frame.origin.x = width-35;
    frame.origin.y = 6;
    self.buttonContainer.frame = frame;
    
    self.container.backgroundColor = [self.item.ID colorForString];
    self.titleLabel.verticalAlignment = JJTextVerticalAlignmentBottom;
    self.titleLabel.frame = CGRectMake(0, self.frame.size.height-titleLabelHeight, width, titleLabelHeight);
    self.timeLabel.hidden = YES;
    
    if ([self.imageList count] > 0){
        self.authorLabel.hidden = !self.showSource;
        self.urlImageView.hidden = NO;
    }else{
        self.authorLabel.hidden = NO;
        self.urlImageView.hidden = YES;
    }
    
    [self updateStarButton];
}

#pragma mark - responder actions
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    [self bringSubviewToFront:self.glowButton];
    self.glowButton.hidden = NO;
    self.glowButton.center = [touch locationInView:self];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    
    [UIView animateWithDuration:0.4f animations:^{
        self.glowButton.alpha = 0.0f;
    } completion:^(BOOL finished){
        self.glowButton.alpha = 1.0f;
        self.glowButton.hidden = YES;
    }];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
}

@end
