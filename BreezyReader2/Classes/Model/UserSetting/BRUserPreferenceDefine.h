//
//  BRUserPreferenceDefine.h
//  BreezyReader2
//
//  Created by 金 津 on 12-5-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserPreferenceDefine.h"

typedef enum{
    BRAccountTypeGoogle,
    BRAccountTypeWeibo,
    BRAccountTypeReadItLater,
    BRAccountTypeInstapaper,
    BRAccountTypeEvernote,
} BRAccountType;

@interface BRUserPreferenceDefine : UserPreferenceDefine

+(NSString*)backgroundImageName;
+(NSInteger)mostReadCount;
+(UIImage*)backgroundImage;
+(void)setDefaultBackgroundImage:(UIImage*)image withName:(NSString*)name;

+(UIColor*)flipThumbnailColor;
+(UIColor*)barColor;

+(BOOL)shouldBlurBackgroundImage;
+(BOOL)autoClearCache;
+(BOOL)shouldLoadAD;
+(BOOL)shouldAutoFlipThumbnail;
+(BOOL)shouldSortByReadingFrequency;
+(BOOL)shouldShowRecommendations;
+(BOOL)shouldAutoRotateImage;
+(BOOL)unreadOnlyStatusForStream:(NSString*)streamID;
+(void)rememberAction:(BOOL)unreadOnly forStream:(NSString*)streamID;
+(NSString*)notificationNameForSwipeRightAction;
+(NSString*)notificationNameForSwipeLeftAction;

@end
