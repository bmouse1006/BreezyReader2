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
#import "BRFeedConfigBase.h"

@interface BRFeedConfigViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) GRSubscription* subscription;
@property (nonatomic, retain) IBOutlet UITableView* tableView;

@property (nonatomic, retain) NSMutableArray* feedOpertaionControllers;

-(void)reloadSectionFromSource:(BRFeedConfigBase*)source;

-(void)showSubscription:(GRSubscription*)subscription;
-(void)showAddNewTagVIew;
-(void)addNewTag;
-(void)addTag:(NSString*)tagID removeTag:(NSString*)tagID;
-(void)unsubscribeButtonClicked;
-(void)subscribeButtonClicked;
-(void)renameButtonClicked;

@end
