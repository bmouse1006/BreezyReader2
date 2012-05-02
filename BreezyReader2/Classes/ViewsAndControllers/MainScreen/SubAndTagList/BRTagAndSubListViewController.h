//
//  BRTagAndSubListViewController.h
//  BreezyReader2
//
//  Created by 金 津 on 12-5-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRBaseController.h"

@interface BRTagAndSubListViewController : BRBaseController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView* tableView;

@end
