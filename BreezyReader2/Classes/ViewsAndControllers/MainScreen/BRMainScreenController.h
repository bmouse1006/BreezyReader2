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

@interface BRMainScreenController : BRBaseController <InfinityScrollViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) InfinityScrollView* infinityScroll;
@property (nonatomic, retain) IBOutlet SideMenuController* sideMenuController;
@property (nonatomic, retain) IBOutlet BRFeedAndArticlesSearchController* searchController;
@property (nonatomic, retain) IBOutlet BRTagAndSubListViewController* allSubListController;
@property (nonatomic, retain) IBOutlet UIView* firstSyncFailedView;
@property (nonatomic, retain) SubOverviewController* subOverrviewController;

-(IBAction)syncReaderFirstTime:(id)sender;

@end
