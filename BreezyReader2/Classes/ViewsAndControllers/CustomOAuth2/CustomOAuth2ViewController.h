//
//  CustomOAuth2ViewController.h
//  BreezyReader2
//
//  Created by  on 12-1-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTMOAuth2ViewControllerTouch.h"

@interface CustomOAuth2ViewController : GTMOAuth2ViewControllerTouch

@property (nonatomic, strong) IBOutlet UIBarButtonItem* backItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* forwardItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* refreshItem;

@property (nonatomic, strong) IBOutlet UIButton* clostItem;

-(IBAction)dismissSelf:(id)sender;

@end
