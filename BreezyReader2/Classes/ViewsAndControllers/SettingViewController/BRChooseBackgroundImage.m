//
//  BRChooseBackgroundImage.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRChooseBackgroundImage.h"
#import "BRUserPreferenceDefine.h"
#import "BRViewControllerNotification.h"

#define kImageName1 @"background1.jpg"
#define kImageName2 @"background2.jpg"
#define kImageName3 @"background3.jpg"

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
    NSString* backgroundImageName = [BRUserPreferenceDefine backgroundImageName];
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
    NSString* imageName = nil;
    if (sender == self.image1Button){
        imageName = kImageName1;
    }else if (sender == self.image2Button){
        imageName = kImageName2;
    }else if (sender == self.image3Button){
        imageName = kImageName3;
    }
    
    if (imageName){
        [BRUserPreferenceDefine setDefaultBackgroundImage:[UIImage imageNamed:imageName] withName:imageName];
    }
    
    [self setNeedsLayout];
}

-(void)chooseImageFromAlbum:(id)sender{
    //selected from album
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICAITON_SETTING_PICKIMAGEFORBACKGROUND object:nil];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    DebugLog(@"media url is %@", [info objectForKey:UIImagePickerControllerMediaURL]);
}

@end
