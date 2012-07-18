//
//  BRFeedControlViewSource.h
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRFeedConfigBase.h"
#import "BRFeedConfigSectionView.h"

@interface BRFeedControlViewSource : BRFeedConfigBase

@property (nonatomic, strong) IBOutlet BRFeedConfigSectionView* sectionView;
@property (nonatomic, strong) IBOutlet UIView* container;

@property (nonatomic, strong) IBOutlet UIButton* greenButton;
@property (nonatomic, strong) IBOutlet UIButton* redButton;

-(IBAction)unsubscriebButtonClicked:(id)sender;
-(IBAction)subscribeButtonClicked:(id)sender;
-(IBAction)renameButtonClicked:(id)sender;

@end
