//
//  BRSettingSource.h
//  BreezyReader2
//
//  Created by 金 津 on 12-5-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRSettingCellActions.h"
#import "BRSettingDataSource.h"

@interface BRSettingSource : NSObject<BRSettingCellActions, BRSettingDataSource>

@property (nonatomic, retain) NSArray* settingConfigs;
@property (nonatomic, copy) NSString* configName;

-(void)moreCellSelectedForIdentifier:(NSString*)identifier;

@end
