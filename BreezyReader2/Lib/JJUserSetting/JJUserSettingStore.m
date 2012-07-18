//
//  JJUserSettingStore.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJUserSettingStore.h"

@implementation JJUserSettingStore

static NSDictionary* _defaultSetting;

+(void)setDefaultSettingFile:(NSString*)filePath{
    NSDictionary* setting = [NSDictionary dictionaryWithContentsOfFile:filePath];
    _defaultSetting = setting;
}



@end
