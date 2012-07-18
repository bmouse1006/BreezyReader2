//
//  WBWeiboComposeViewController.h
//  SocialAuthTest
//
//  Created by Jin Jin on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthController.h"

@interface WBWeiboComposeViewController : UIViewController<OAuthControllerDelegate, UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UIView* backgroundView;
@property (nonatomic, strong) IBOutlet UIView* composeDialog;
@property (nonatomic, strong) IBOutlet UIToolbar* toolBar;

@property (nonatomic, strong) IBOutlet UIView* sepertorLine;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, strong) IBOutlet UITextView* textView;
@property (nonatomic, strong) IBOutlet UIImageView* contentImageView;

@property (nonatomic, strong) IBOutlet UIView* contentContainer;
@property (nonatomic, strong) IBOutlet UIView* contentView;

@property (nonatomic, strong) IBOutlet UIButton* checkedButton;

-(void)addInitialText:(NSString*)text;
-(void)addImage:(UIImage*)image;
-(void)addURLString:(NSString*)urlString;

-(void)show:(BOOL)animated;

-(IBAction)share:(id)sender;
-(IBAction)close:(id)sender;

-(BOOL)isAutherized;
-(void)logout;

+(id)sharedController;
//+(id)controller;

@end
