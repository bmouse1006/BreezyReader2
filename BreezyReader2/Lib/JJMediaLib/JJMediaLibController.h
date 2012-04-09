//
//  JJMediaLibController.h
//  BreezyReader2
//
//  Created by  on 12-2-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJMediaSource.h"
#import "JJMediaDataSource.h"
#import "JJMediaLibTableViewCell.h"

@interface JJMediaLibController : UIViewController<JJMediaLibTableViewCellDelegate>

@property (nonatomic, retain) JJMediaDataSource* dataSource;
@property (nonatomic, retain) id<JJMediaSource> mediaSource;

@property (nonatomic, retain) IBOutlet UITableView* tableView;

-(void)assignMediaSource:(id<JJMediaSource>)source;
-(CGFloat)thumbSize;
-(CGFloat)thumbSpacing;
-(CGFloat)rowHeight;

-(id<UITableViewDataSource>)generateDataSourceWithMediaSource:(id<JJMediaSource>)source;

@end
