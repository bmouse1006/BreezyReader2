//
//  BRFeedDragDownController.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRFeedDragDownController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* timeLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* indicator;

-(void)pullToRefresh;
-(void)readyToRefresh;
-(void)refresh;

-(void)refreshLabels:(NSDate*)date;

@end
