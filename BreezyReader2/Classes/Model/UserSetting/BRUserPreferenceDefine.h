//
//  BRUserPreferenceDefine.h
//  BreezyReader2
//
//  Created by 金 津 on 12-5-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserPreferenceDefine.h"

@interface BRUserPreferenceDefine : UserPreferenceDefine

+(UIImage*)backgroundImage;
+(NSString*)backgroundImageName;
+(NSInteger)mostReadCount;
+(void)setDefaultBackgroundImageName:(NSString*)imageName;

+(BOOL)shouldLoadAD;

@end
