//
//  BRImageScrollController.m
//  BreezyReader2
//
//  Created by Jin Jin on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRImageScrollController.h"
#import "UIViewController+BRAddtion.h"
#import "BRAlertHandler.h"
#import <QuartzCore/QuartzCore.h>

@interface BRImageScrollController ()

@end

@implementation BRImageScrollController

@synthesize saveButton = _saveButton;

-(void)dealloc{
    self.saveButton = nil;
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
    self.saveButton.layer.masksToBounds = YES;
    self.saveButton.layer.cornerRadius = 5;
    [self.view addSubview:self.saveButton];
    CGRect frame = self.saveButton.frame;
    frame.origin.x = self.view.frame.size.width - frame.size.width - 20;
    frame.origin.y = self.view.frame.size.height - frame.size.height - 25;
    self.saveButton.frame = frame;
    
    self.scrollView.showPageControl = YES;
    self.scrollView.pageControlHorizonAlignment = JJHorizonAlignmentMiddle;
    self.scrollView.pageControlVerticalAlignment = JJVerticalAlignmentBottom;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
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

@end
