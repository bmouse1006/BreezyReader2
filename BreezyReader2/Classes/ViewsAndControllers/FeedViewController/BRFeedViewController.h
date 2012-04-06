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
#import "JJActivityView.h"
#import "JJImageView.h"
#import "JJLabel.h"

@interface BRFeedViewController : BRBaseController <UITableViewDelegate, BRBaseDataSourceDelegate>

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet BRFeedDragDownController* dragController;
@property (nonatomic, retain) IBOutlet BRFeedLoadMoreController* loadMoreController;

@property (nonatomic, retain) IBOutlet UIView* loadingView;
@property (nonatomic, retain) IBOutlet UIView* titleView;
@property (nonatomic, retain) IBOutlet JJLabel* titleLabel;
@property (nonatomic, retain) IBOutlet JJImageView* titleIcon;
@property (nonatomic, retain) IBOutlet UIView* bottomToolBar;
@property (nonatomic, retain) IBOutlet UIButton* backButton;

@property (nonatomic, retain) GRSubscription* subscription;
@property (nonatomic, retain) BRFeedDataSource* dataSource;

@property (nonatomic, retain) IBOutlet JJActivityView* activityView;

-(IBAction)backButtonClicked:(id)sender;
-(IBAction)scrollToTop:(id)sender;

@end


