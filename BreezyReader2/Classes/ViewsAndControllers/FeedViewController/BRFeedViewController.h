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

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet BRFeedDragDownController* dragController;
@property (nonatomic, strong) IBOutlet BRFeedLoadMoreController* loadMoreController;
@property (nonatomic, strong) IBOutlet BRFeedConfigViewController* configViewController;

@property (nonatomic, strong) IBOutlet UIView* loadingView;
@property (nonatomic, strong) IBOutlet JJLabel* loadingLabel;
@property (nonatomic, strong) IBOutlet UIView* noMoreView;
@property (nonatomic, strong) IBOutlet UILabel* noMoreLabel;

@property (nonatomic, strong) IBOutlet UIView* titleView;
@property (nonatomic, strong) IBOutlet JJLabel* titleLabel;
@property (nonatomic, strong) IBOutlet BRBottomToolBar* bottomToolBar;
@property (nonatomic, strong) IBOutlet UIButton* menuButton;

@property (nonatomic, strong) IBOutlet UIButton* configButton;

@property (nonatomic, strong) GRSubscription* subscription;
@property (nonatomic, strong) BRFeedDataSource* dataSource;

-(IBAction)backButtonClicked:(id)sender;
-(IBAction)configButtonClicked:(id)sender;
-(IBAction)scrollToTop:(id)sender;
-(IBAction)showActionMenuButtonClicked:(id)sender;

@end


