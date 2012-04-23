//
//  BRFeedControlViewController.h
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRFeedConfigBase.h"
#import "BRFeedLabelsViewController.h"

@interface BRFeedControlViewController : BRFeedLabelsViewController

@property (nonatomic, retain) IBOutlet UIView* container;

-(IBAction)unsubscriebButtonClicked:(id)sender;
-(IBAction)renameButtonClicked:(id)sender;

@end
