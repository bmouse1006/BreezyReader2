//
//  BRFeedTableViewCell.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedTableViewCell.h"
#import "BRImagePreviewCache.h"

#define kCellLeftSpacing 7.0f
#define kCellRightSpacing 7.0f

@interface BRFeedTableViewCell ()

@end

@implementation BRFeedTableViewCell

@synthesize item = _item;
@synthesize urlImageView = _urlImageView;
@synthesize container = _container;
@synthesize titleLabel = _titleLabel;
@synthesize bottomSeperateLine = _bottomSeperateLine;
@synthesize previewLabel = _previewLabel;
@synthesize timeLabel = _timeLabel;
@synthesize imageList = _imageList;
@synthesize authorLabel = _authorLabel;
@synthesize unstarButton = _unstarButton, starButton = _starButton;
@synthesize buttonContainer = _buttonContainer;

-(void)dealloc{
    self.item = nil;
    self.urlImageView = nil;
    self.container = nil;
    self.titleLabel = nil;
    self.bottomSeperateLine = nil;
    self.previewLabel = nil;
    self.timeLabel = nil;
    self.imageList = nil;
    self.authorLabel = nil;
    self.buttonContainer = nil;
    [super dealloc];
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
    [super awakeFromNib];
    self.titleLabel.verticalAlignment = JJTextVerticalAlignmentTop;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    self.titleLabel.textColor = [UIColor blackColor];
    
    self.previewLabel.verticalAlignment = JJTextVerticalAlignmentTop;
    self.previewLabel.font = [UIFont systemFontOfSize:13];
    self.previewLabel.textColor = [UIColor darkGrayColor];
    
    self.timeLabel.verticalAlignment = JJTextVerticalAlignmentBottom;
    self.timeLabel.font = [UIFont systemFontOfSize:10];
    self.timeLabel.textColor = [UIColor lightGrayColor];
    self.timeLabel.textAlignment = UITextAlignmentRight;
    
    self.authorLabel.verticalAlignment = JJTextVerticalAlignmentBottom;
    self.authorLabel.font = [UIFont systemFontOfSize:10];
    self.authorLabel.textColor = [UIColor lightGrayColor];
    
    self.urlImageView.defaultImage = [UIImage imageNamed:@"photo"];
    self.urlImageView.defautImageMode = UIViewContentModeCenter;
    self.urlImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.contentView addSubview:self.container];
}

-(void)setItem:(GRItem *)item{
    if (_item != item){
        [_item release];
        _item = [item retain];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self registerNotifications];
        
        self.imageList = [[BRImagePreviewCache sharedCache] cachedPreviewImagesForKey:_item.ID];
        if (self.imageList == nil){
            self.imageList = [_item imageURLList]; 
            [[BRImagePreviewCache sharedCache] storeImagePreviews:self.imageList key:_item.ID];
        }
        
        if ([self.imageList count] == 0){
            self.urlImageView.imageURL = nil;
        }else{
            
            self.urlImageView.imageURL = [NSURL URLWithString:[self.imageList objectAtIndex:0]];
        }
        
        self.titleLabel.text = _item.title;
        self.timeLabel.text = [_item getShortUpdatedDateTime];
        
        NSString* previewContent = nil;
        if (_item.plainContent.length != 0){
            previewContent = _item.plainContent;
        }else if (_item.plainSummary != 0){
            previewContent = _item.plainSummary;
        }
        
        self.previewLabel.text = previewContent ;
        
        self.authorLabel.text = _item.author;
    }
    [self setNeedsLayout];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    //layout bottom line
    CGRect frame = self.bottomSeperateLine.frame;
    frame.size.height = 0.5f;
    frame.size.width = bounds.size.width-(kCellLeftSpacing + kCellRightSpacing);
    frame.origin.x = kCellLeftSpacing;
    frame.origin.y = bounds.size.height - frame.size.height;
    [self.bottomSeperateLine setFrame:frame];
    
    CGFloat leftSpacing = kCellLeftSpacing;
    //layout preview image
    if ([self.imageList count] == 0){
        self.urlImageView.hidden = YES;
    }else {
        self.urlImageView.hidden = NO;
        leftSpacing += self.urlImageView.bounds.size.width + kCellLeftSpacing;
    }
    //layout text labels
//    CGPoint starCenter = CGPointMake(<#CGFloat x#>, <#CGFloat y#>)
    frame = self.titleLabel.frame;
    frame.origin.x = leftSpacing;
    frame.size.width = bounds.size.width - (leftSpacing + kCellRightSpacing + self.buttonContainer.frame.size.width);
    frame.size.height = 40;
    
    [self.titleLabel setFrame:frame];
    
    frame = self.previewLabel.frame;
    frame.origin.x = leftSpacing;
    frame.origin.y = self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height;
    frame.size.width = bounds.size.width - (leftSpacing + kCellRightSpacing);
    frame.size.height = 73.0f - (self.titleLabel.frame.origin.y + 40);
    [self.previewLabel setFrame:frame];
    
    frame = self.authorLabel.frame;
    frame.origin.x = leftSpacing;
    [self.authorLabel setFrame:frame];
    [self updateStarButton];
    [self updateReadColor];
}

-(void)updateStarButton{
    [self.buttonContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (self.item.isReadStateLocked){
        return;
    }
    if (_item.isStarred){
        [self.buttonContainer addSubview:self.unstarButton];
    }else{
        [self.buttonContainer addSubview:self.starButton];
    }
}

-(void)updateReadColor{
    if (self.item.isReadStateLocked){
        return;
    }
    if (self.item.isReaded){
        self.titleLabel.textColor = [UIColor grayColor];
    }else{
        self.titleLabel.textColor = [UIColor blackColor];
    }
}

#pragma mark - button call back

-(IBAction)starButtonClicked:(id)sender{
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:self.item.ID forKey:@"itemID"];
    NSNotification* notification = [NSNotification notificationWithName:NOTIFICATION_STARITEM object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(IBAction)unstarButtonClicked:(id)sender{
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:self.item.ID forKey:@"itemID"];
    NSNotification* notification = [NSNotification notificationWithName:NOTIFICATION_UNSTARITEM object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark - notification register

-(void)registerNotifications{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(addStarSuccess:) name:NOTIFICATION_STARSUCCESS object:self.item.ID];
    [nc addObserver:self selector:@selector(removeStarSuccess:) name:NOTIFICATION_UNSTARSUCCESS object:self.item.ID];
}

#pragma mark - notification 
-(void)addStarSuccess:(NSNotification*)notification{
    DebugLog(@"add star success");
    [self animateTransitionView1:self.starButton view2:self.unstarButton];
}

-(void)removeStarSuccess:(NSNotification*)notification{
    DebugLog(@"remove star success");
    [self animateTransitionView1:self.unstarButton view2:self.starButton];
}

-(void)animateTransitionView1:(UIView*)view1 view2:(UIView*)view2{
    [view1.superview addSubview:view2];
    [UIView transitionFromView:view1 toView:view2 duration:0.2 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished){
        [view1 removeFromSuperview];
    }];
}

@end
