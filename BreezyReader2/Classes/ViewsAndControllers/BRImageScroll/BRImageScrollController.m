//
//  BRImageScrollController.m
//  BreezyReader2
//
//  Created by Jin Jin on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRImageScrollController.h"
#import "UIViewController+BRAddition.h"
#import "BRAlertHandler.h"
#import "BRUserPreferenceDefine.h"
#import <QuartzCore/QuartzCore.h>

@interface BRImageScrollController ()

@end

@implementation BRImageScrollController

@synthesize saveButton = _saveButton;
@synthesize buttonContainer = _buttonContainer;
@synthesize buttonBackground = _buttonBackground;

-(void)dealloc{
    self.saveButton = nil;
    self.buttonBackground = nil;
    self.buttonContainer = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //add save button
//    self.saveButton.clipsToBounds = YES;
    self.buttonBackground.layer.masksToBounds = YES;
    self.buttonBackground.layer.cornerRadius = 8.0f;
//    [self.view addSubview:self.buttonContainer];
    
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.scrollView.showPageControl = YES;
    self.scrollView.pageControlHorizonAlignment = JJHorizonAlignmentMiddle;
    self.scrollView.pageControlVerticalAlignment = JJVerticalAlignmentBottom;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGRect frame = self.buttonContainer.frame;
    frame.origin.x = self.view.frame.size.width - frame.size.width - 10;
    frame.origin.y = self.view.frame.size.height - frame.size.height - 20;
    self.buttonContainer.frame = frame;
    DebugLog(@"%@", NSStringFromCGRect(self.buttonContainer.frame));
//    self.scrollView.bounds = self.view.bounds;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

-(void)oritationDidChange:(NSNotification*)notification{
    if ([self shouldAutorotateImage]){
        [super oritationDidChange:notification];
    }
}

#pragma mark - actions
-(void)singelTapAction:(UITapGestureRecognizer*)singleTap{
    [[self topContainer] popViewController:YES];
}

-(void)saveButtonClicked:(id)sender{
    UIImage* image = [self imageAtIndex:[self.scrollView currentIndex]];
    if (image != nil){
        UIImageWriteToSavedPhotosAlbum(image,nil,NULL,nil);
        [BRAlertHandler promptAlertString:NSLocalizedString(@"msg_imagesaved", nil)];
    }else{
        //notify not loaded
        [BRAlertHandler promptAlertString:NSLocalizedString(@"msg_imagenotloaded", nil)];
    }
}

#pragma mark - auto rotate
-(BOOL)shouldAutorotateImage{
    return [BRUserPreferenceDefine shouldAutoRotateImage];
}

@end
