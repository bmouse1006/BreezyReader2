//
//  BRUserVerifyController.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRBaseController.h"

@interface BRUserVerifyController : BRBaseController

@property (nonatomic, strong) IBOutlet UIButton* loginButton;

-(IBAction)loginButtonClicked:(id)sender;

-(IBAction)signout:(id)sender;

@end
