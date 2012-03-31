//
//  BRFeedAndArticlesSearchController.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRSearchDataSource.h"

@interface BRFeedAndArticlesSearchController : UIViewController<UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDelegate, BRSearchDelegate>

@property (nonatomic, retain) IBOutlet UIView* loadMoreView;
@property (nonatomic, retain) IBOutlet UIButton* loadMoreButton;

-(void)getReadyForSearch;

-(void)dismissSearchView;

-(IBAction)loadMoreButtonClicked:(id)sender;

@end
