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
#import "MOGlassButton.h"

@interface BRFeedControlViewSource : BRFeedConfigBase

@property (nonatomic, retain) IBOutlet BRFeedConfigSectionView* sectionView;
@property (nonatomic, retain) IBOutlet UIView* container;

@property (nonatomic, retain) IBOutlet MOGlassButton* greenButton;
@property (nonatomic, retain) IBOutlet MOGlassButton* redButton;

-(IBAction)unsubscriebButtonClicked:(id)sender;
-(IBAction)subscribeButtonClicked:(id)sender;
-(IBAction)renameButtonClicked:(id)sender;

@end
