//
//  BRFeedActionMenuViewController.h
//  BreezyReader2
//
//  Created by Jin Jin on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRFeedActionMenuViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIView* menu;

-(void)dismiss;

-(void)showMenuInPosition:(CGPoint)position anchorPoint:(CGPoint)anchor;

-(IBAction)showUnreadOnlyButtonClicked:(id)sender;
-(IBAction)showAllArticlesButtonClicked:(id)sender;
-(IBAction)markAllAsReadButtonClicked:(id)sender;

@end
