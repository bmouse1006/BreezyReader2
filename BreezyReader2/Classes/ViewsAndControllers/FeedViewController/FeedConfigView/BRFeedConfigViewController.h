//
//  BRFeedConfigViewController.h
//  BreezyReader2
//
//  Created by 金 津 on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRSubscription.h"
#import "JJLabel.h"

@interface BRFeedConfigViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) GRSubscription* subscription;
@property (nonatomic, retain) IBOutlet UITableView* tableView;

@property (nonatomic, retain) NSMutableArray* feedOpertaionControllers;

@end
