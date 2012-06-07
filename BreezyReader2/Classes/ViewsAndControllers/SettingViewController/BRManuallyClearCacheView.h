//
//  BRManuallyClearCacheView.h
//  BreezyReader2
//
//  Created by Jin Jin on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRSettingCustomBaseView.h"

@interface BRManuallyClearCacheView : BRSettingCustomBaseView

@property (nonatomic, retain) IBOutlet UIButton* button;

-(IBAction)clearCache:(id)sender;

@end
