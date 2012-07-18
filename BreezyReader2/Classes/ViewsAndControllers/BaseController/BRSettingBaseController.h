//
//  BRSettingBaseController.h
//  BreezyReader2
//
//  Created by 金 津 on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRSettingDataSource.h"

@interface BRSettingBaseController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@property (nonatomic, strong) NSMutableArray* settingDataSources;

-(void)reloadSectionFromSource:(id<BRSettingDataSource>)source;
-(void)reloadRowsFromSource:(id<BRSettingDataSource>)source row:(NSInteger)row animated:(BOOL)animated;

@end
