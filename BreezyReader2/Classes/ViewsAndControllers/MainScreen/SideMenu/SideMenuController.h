//
//  SideMenuController.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuController : UIViewController

-(IBAction)searchButtonClicked:(id)sender;
-(IBAction)downloadButtonClicked:(id)sender;

-(IBAction)configButtonClicked:(id)sender;
-(IBAction)logoutButtonClicked:(id)sender;

-(IBAction)starButtonClicked:(id)sender;
-(IBAction)showSubListButtonClicked:(id)sender;

-(IBAction)reloadButtonClicked:(id)sender;

@end
