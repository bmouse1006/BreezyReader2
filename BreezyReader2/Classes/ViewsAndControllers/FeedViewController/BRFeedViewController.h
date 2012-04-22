//
//  BRFeedViewController.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRSubscription.h"
#import "GRItem.h"
#import "BRFeedDataSource.h"
#import "BRBaseController.h"
#import "BRFeedDragDownController.h"
#import "BRFeedLoadMoreController.h"
#import "BRFeedActionMenuViewController.h"
#import "JJImageView.h"
#import "JJLabel.h"
#import "BRBottomToolBar.h"
#import "BRFeedConfigViewController.h"

@interface BRFeedViewController : BRBaseController <UITableViewDelegate, BRBaseDataSourceDelegate>

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet BRFeedDragDownController* dragController;
@property (nonatomic, retain) IBOutlet BRFeedLoadMoreController* loadMoreController;
@property (nonatomic, retain) IBOutlet BRFeedActionMenuViewController* actionMenuController;
@property (nonatomic, retain) IBOutlet BRFeedConfigViewController* configViewController;

@property (nonatomic, retain) IBOutlet UIView* loadingView;
@property (nonatomic, retain) IBOutlet JJLabel* loadingLabel;

@property (nonatomic, retain) IBOutlet UIView* titleView;
@property (nonatomic, retain) IBOutlet JJLabel* titleLabel;
@property (nonatomic, retain) IBOutlet BRBottomToolBar* bottomToolBar;
@property (nonatomic, retain) IBOutlet UIButton* menuButton;

@property (nonatomic, retain) GRSubscription* subscription;
@property (nonatomic, retain) BRFeedDataSource* dataSource;

-(IBAction)backButtonClicked:(id)sender;
-(IBAction)configButtonClicked:(id)sender;
-(IBAction)scrollToTop:(id)sender;
-(IBAction)showActionMenuButtonClicked:(id)sender;

@end


