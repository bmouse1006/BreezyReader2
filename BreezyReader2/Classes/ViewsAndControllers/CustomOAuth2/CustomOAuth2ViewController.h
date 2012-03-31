//
//  CustomOAuth2ViewController.h
//  BreezyReader2
//
//  Created by  on 12-1-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMOAuthViewControllerTouch.h"

@interface CustomOAuth2ViewController : GTMOAuth2ViewControllerTouch

@property (nonatomic, retain) IBOutlet UIBarButtonItem* backItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* forwardItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* refreshItem;

@property (nonatomic, retain) IBOutlet UIButton* clostItem;

-(IBAction)dismissSelf:(id)sender;

@end
