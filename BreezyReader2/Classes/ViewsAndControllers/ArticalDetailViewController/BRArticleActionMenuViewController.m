//
//  BRArticleActionMenuViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRArticleActionMenuViewController.h"
#import "BRViewControllerNotification.h"

@interface BRArticleActionMenuViewController ()

@end

@implementation BRArticleActionMenuViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - button actions
-(IBAction)twitterButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHARE_TWITTER object:nil];
}

-(IBAction)evernoteButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHARE_EVERNOTE object:nil];
}

-(IBAction)weiboButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHARE_WEIBO object:nil];
}

-(IBAction)mailButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHARE_MAIL object:nil];
}

-(IBAction)instapaperButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHARE_INSTAPAPER object:nil];
}

-(IBAction)readItLaterButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHARE_READITLATER object:nil];
}

@end
