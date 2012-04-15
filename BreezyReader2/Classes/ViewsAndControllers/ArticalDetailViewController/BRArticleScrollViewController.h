//
//  BRArticleScrollViewController.h
//  BreezyReader2
//
//  Created by 金 津 on 12-4-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJPageScrollView.h"
#import "GRFeed.h"
#import "BRBottomToolBar.h"

@interface BRArticleScrollViewController : UIViewController<JJPageScrollViewDelegate, JJPageScrollViewDataSource>

@property (nonatomic, retain) IBOutlet JJPageScrollView* scrollView;
@property (nonatomic, retain) IBOutlet BRBottomToolBar* bottomToolBar;

@property (nonatomic, retain) GRFeed* feed;
@property (nonatomic, assign) NSUInteger index;

@property (nonatomic, retain) IBOutlet UIButton* backButton;
@property (nonatomic, retain) IBOutlet UIButton* starButton;
@property (nonatomic, retain) IBOutlet UIButton* unstarButton;
@property (nonatomic, retain) IBOutlet UIView* starButtonContainer;

-(IBAction)back:(id)sender;
-(IBAction)viewInSafari:(id)sender;
-(IBAction)starItem:(id)sender;
-(IBAction)unstarItem:(id)sender;
-(IBAction)scrollCurrentPageToTop:(id)sender;
-(IBAction)showHideFontsizeMenu:(id)sender;

@end
