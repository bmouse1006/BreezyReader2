//
//  BRChooseBackgroundImage.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRChooseBackgroundImage.h"
#import "UserPreferenceDefine.h"

@implementation BRChooseBackgroundImage

@synthesize image1Button = _image1Button, image2Button = _image2Button, image3Button = _image3Button, userImageButton = _userImageButton;

-(void)dealloc{
    self.image1Button = nil;
    self.image2Button = nil;
    self.image3Button = nil;
    self.userImageButton = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+(CGFloat)heightForCustomView{
    return 116.0f;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.image1Button.highlighted = NO;
    self.image2Button.highlighted = NO;
    self.image3Button.highlighted = NO;
    NSString* backgroundImageName = [UserPreferenceDefine backgroundImageName];
    if ([backgroundImageName isEqualToString:@"background1.jpg"]){
        self.image1Button.highlighted = YES;
    }else if ([backgroundImageName isEqualToString:@"background2.jpg"]){
        self.image2Button.highlighted = YES;
    }else if ([backgroundImageName isEqualToString:@"background3.jpg"]){
        self.image3Button.highlighted = YES;
    }else {
        
    }
}

-(void)imageButtonClicked:(id)sender{
    if (sender == self.image1Button){
        [UserPreferenceDefine setDefaultBackgroundImageName:@"background1.jpg"];
    }else if (sender == self.image2Button){
        [UserPreferenceDefine setDefaultBackgroundImageName:@"background2.jpg"];
    }else if (sender == self.image3Button){
        [UserPreferenceDefine setDefaultBackgroundImageName:@"background3.jpg"];
    }
    
    [self setNeedsLayout];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
