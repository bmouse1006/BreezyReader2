//
//  BRUserPreferenceDefine.h
//  BreezyReader2
//
//  Created by 金 津 on 12-5-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserPreferenceDefine.h"

@interface BRUserPreferenceDefine : UserPreferenceDefine

+(NSString*)backgroundImageName;
+(NSInteger)mostReadCount;
+(UIImage*)backgroundImage;
+(void)setDefaultBackgroundImage:(UIImage*)image withName:(NSString*)name;

+(UIColor*)flipThumbnailColor;

+(BOOL)shouldLoadAD;

@end
