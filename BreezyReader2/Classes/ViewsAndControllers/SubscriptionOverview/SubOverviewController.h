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

@property (nonatomic, strong) IBOutlet UIView* dimBackground;
@property (nonatomic, strong) IBOutlet UIView* container;
@property (nonatomic, strong) IBOutlet UIButton* dismissButton;
@property (nonatomic, strong) IBOutlet UIView* subDetailView;

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* subscriberCountLabel;
@property (nonatomic, strong) IBOutlet UILabel* velocityLabel;

-(void)showOverviewForSub:(GRSubscription*)sub inView:(UIView*)view flipFrom:(UIView*)originView;

-(IBAction)dismiss:(id)sender;

@end
