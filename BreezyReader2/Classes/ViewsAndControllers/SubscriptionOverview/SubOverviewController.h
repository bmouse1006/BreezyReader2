//
//  SubOverviewController.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRSubscription.h"
#import "JJImageView.h"

@interface SubOverviewController : UIViewController

@property (nonatomic, retain) IBOutlet UIView* dimBackground;
@property (nonatomic, retain) IBOutlet UIView* container;
@property (nonatomic, retain) IBOutlet UIButton* dismissButton;
@property (nonatomic, retain) IBOutlet UIView* subDetailView;

@property (nonatomic, retain) IBOutlet UILabel* titleLabel;
@property (nonatomic, retain) IBOutlet UILabel* subscriberCountLabel;
@property (nonatomic, retain) IBOutlet UILabel* velocityLabel;

-(void)showOverviewForSub:(GRSubscription*)sub inView:(UIView*)view flipFrom:(UIView*)originView;

-(IBAction)dismiss:(id)sender;

@end
