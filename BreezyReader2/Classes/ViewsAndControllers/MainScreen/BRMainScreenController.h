//
//  BRMainScreenController.h
//  BreezyReader2
//
//  Created by 金 津 on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRBaseController.h"
#import "InfinityScrollView.h"
#import "SideMenuController.h"
#import "BRFeedAndArticlesSearchController.h"
#import "SubOverviewController.h"
#import "BRTagAndSubListViewController.h"
#import "BaseView.h"
#import "JJLabel.h"

@interface BRMainScreenController : BRBaseController <InfinityScrollViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BaseViewDelegate>

@property (nonatomic, strong) InfinityScrollView* infinityScroll;
@property (nonatomic, strong) IBOutlet SideMenuController* sideMenuController;
@property (nonatomic, strong) IBOutlet BRFeedAndArticlesSearchController* searchController;
@property (nonatomic, strong) IBOutlet BRTagAndSubListViewController* allSubListController;
@property (nonatomic, strong) IBOutlet UIView* firstSyncFailedView;
@property (nonatomic, strong) SubOverviewController* subOverrviewController;

@property (nonatomic, strong) IBOutlet JJLabel* noteLabel;

-(IBAction)syncReaderFirstTime:(id)sender;

@end
