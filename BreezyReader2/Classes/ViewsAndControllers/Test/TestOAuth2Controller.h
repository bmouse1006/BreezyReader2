//
//  TestOAuth2Controller.h
//  BreezyReader2
//
//  Created by 金 津 on 12-1-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2Authentication.h"

@interface TestOAuth2Controller : UIViewController

@property (nonatomic, retain) NSMutableData* data;
@property (nonatomic, retain) GTMOAuth2Authentication* auth;
@property (nonatomic, retain) IBOutlet UIWebView* webView;

-(IBAction)login:(id)sender;
-(IBAction)logout:(id)sender;
-(IBAction)showList:(id)sender;
-(IBAction)showAtomFeed:(id)sender;

@end
