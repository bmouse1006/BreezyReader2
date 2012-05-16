//
//  BRChooseBackgroundImage.h
//  BreezyReader2
//
//  Created by 金 津 on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRSettingCustomBaseView.h"

@interface BRChooseBackgroundImage : BRSettingCustomBaseView<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) IBOutlet UIButton* image1Button;
@property (nonatomic, retain) IBOutlet UIButton* image2Button;
@property (nonatomic, retain) IBOutlet UIButton* image3Button;
@property (nonatomic, retain) IBOutlet UIButton* userImageButton;

-(IBAction)imageButtonClicked:(id)sender;
-(IBAction)chooseImageFromAlbum:(id)sender;

@end
