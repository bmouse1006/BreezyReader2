//
//  BRRelatedFeedViewSource.h
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRFeedConfigBase.h"
#import "BRFeedConfigSectionView.h"

@interface BRRelatedFeedViewSource : BRFeedConfigBase

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* activity;
@property (nonatomic, retain) IBOutlet BRFeedConfigSectionView* sectionView;

@end
