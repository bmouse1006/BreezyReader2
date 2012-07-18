//
//  BRFeedActionMenuViewController.m
//  BreezyReader2
//
//  Created by Jin Jin on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedActionMenuViewController.h"
#import "BRViewControllerNotification.h"

@interface BRFeedActionMenuViewController (){
    BRFeedActoinMenuStatus _status;
}

@end

@implementation BRFeedActionMenuViewController

@synthesize showAllButton = _showAllButton, unreadOnlyButton = _unreadOnlyButton, markAllAsReadButton = _markAllAsReadButton;


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
//    self.view.autoresizingMask = UIViewAuto;
    
    [self.markAllAsReadButton setTitle:NSLocalizedString(@"title_markallasread", nil) forState:UIControlStateNormal];
    [self.showAllButton setTitle:NSLocalizedString(@"title_showallarticles", nil) forState:UIControlStateNormal];
    [self.unreadOnlyButton setTitle:NSLocalizedString(@"title_unreadonly", nil) forState:UIControlStateNormal];
    
    [self refreshButtonsByStatus:_status];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.unreadOnlyButton = nil;
    self.showAllButton = nil;
    self.markAllAsReadButton = nil;
}

-(void)viewDidLayoutSubviews{
    self.menu.frame = self.view.bounds;
}

-(void)dismiss{
    [super dismiss];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MENUACTION_DISAPPEAR object:self.menu];
}

-(IBAction)showUnreadOnlyButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MENUACTION_UNREADONLY object:sender];
    _status = BRFeedActoinMenuStatusUnreadOnly;
    [self refreshButtonsByStatus:_status];
    [self dismiss];
}

-(IBAction)showAllArticlesButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICAITON_MENUACTION_ALLARTICLES object:sender];
    _status = BRFeedActoinMenuStatusShowAllArticles;
    [self refreshButtonsByStatus:_status];
    [self dismiss];
}

-(IBAction)markAllAsReadButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MENUACTION_MARKALLASREAD object:sender];
    [self dismiss];
}

-(void)setActionStatus:(BRFeedActoinMenuStatus)status{ 
    _status = status;
    [self refreshButtonsByStatus:_status];
}

-(void)refreshButtonsByStatus:(BRFeedActoinMenuStatus)status{
    UIImage* checkMark = [UIImage imageNamed:@"checkmark"];
    switch (status) {
        case BRFeedActoinMenuStatusUnreadOnly:
            [self.unreadOnlyButton setImage:checkMark forState:UIControlStateNormal];
            [self.showAllButton setImage:nil forState:UIControlStateNormal];
            break;
        case BRFeedActoinMenuStatusShowAllArticles:
            [self.showAllButton setImage:checkMark forState:UIControlStateNormal];
            [self.unreadOnlyButton setImage:nil forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

@end
