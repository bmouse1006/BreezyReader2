//
//  SideMenuController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SideMenuController.h"
#import "BRViewControllerNotification.h"

@interface SideMenuController ()

@end

@implementation SideMenuController

@synthesize buyButton = _buyButton;

-(void)dealloc{
    self.buyButton = nil;
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
    // Do any additional setup after loading the view from its nib.
#ifdef FREEVERSION
    self.buyButton.hidden = NO;
#else
    self.buyButton.hidden = YES;
#endif
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

-(IBAction)searchButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SERACHBUTTONCLICKED object:sender];
}

-(IBAction)downloadButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DOWNLOADBUTTONCLICKED object:sender];
}

-(IBAction)logoutButtonClicked:(id)sender{
     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOGOUTBUTTONCLICKED object:sender];
}

-(IBAction)configButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONFIGBUTTONCLICKED object:sender];   
}

-(IBAction)starButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STARBUTTONCLICKED object:sender];  
}

-(IBAction)showSubListButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOWSUBLISTBUTTONCLICKED object:sender];  
}

-(IBAction)reloadButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RELOADBUTTONCLICKED object:sender];      
}

-(IBAction)buyButtonClicked:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BUYBUTTONCLICKED object:sender];  
}

@end
