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
#import "BRArticleActionMenuViewController.h"
#import "BRBaseController.h"

@interface BRArticleScrollViewController : BRBaseController<JJPageScrollViewDelegate, JJPageScrollViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet JJPageScrollView* scrollView;
@property (nonatomic, strong) IBOutlet BRBottomToolBar* bottomToolBar;

@property (nonatomic, strong) GRFeed* feed;
@property (nonatomic, assign) NSUInteger index;

@property (nonatomic, strong) IBOutlet UIButton* backButton;
@property (nonatomic, strong) IBOutlet UIButton* starButton;
@property (nonatomic, strong) IBOutlet UIButton* unstarButton;
@property (nonatomic, strong) IBOutlet UIView* starButtonContainer;
@property (nonatomic, strong) IBOutlet UIButton* leftScrollButton;
@property (nonatomic, strong) IBOutlet UIButton* rightScrollButton;

@property (nonatomic, strong) IBOutlet BRArticleActionMenuViewController* actionMenuController;

-(IBAction)back:(id)sender;
-(IBAction)viewInSafari:(id)sender;
-(IBAction)starItem:(id)sender;
-(IBAction)unstarItem:(id)sender;
-(IBAction)scrollCurrentPageToTop:(id)sender;
-(IBAction)showHideFontsizeMenu:(id)sender;
-(IBAction)favoriteActionButtonClicked:(id)sender;

-(IBAction)showHideActionMenuButtonClicked:(id)sender;

-(IBAction)scrollToNextPage:(id)sender;
-(IBAction)scrollToPreviousPage:(id)sender;

@end
