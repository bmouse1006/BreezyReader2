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

@property (nonatomic, retain) IBOutlet UIView* backgroundView;
@property (nonatomic, retain) IBOutlet UIView* composeDialog;
@property (nonatomic, retain) IBOutlet UIToolbar* toolBar;

@property (nonatomic, retain) IBOutlet UIView* sepertorLine;
@property (nonatomic, retain) IBOutlet UILabel* titleLabel;

@property (nonatomic, retain) IBOutlet UITextView* textView;
@property (nonatomic, retain) IBOutlet UIImageView* contentImageView;

@property (nonatomic, retain) IBOutlet UIView* contentContainer;
@property (nonatomic, retain) IBOutlet UIView* contentView;

@property (nonatomic, retain) IBOutlet UIButton* checkedButton;

-(void)addInitialText:(NSString*)text;
-(void)addImage:(UIImage*)image;
-(void)addURLString:(NSString*)urlString;

-(void)show:(BOOL)animated;

-(IBAction)share:(id)sender;
-(IBAction)close:(id)sender;

+(id)sharedController;
+(id)controller;

@end
