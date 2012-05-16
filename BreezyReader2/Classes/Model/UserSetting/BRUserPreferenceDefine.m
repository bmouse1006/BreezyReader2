//
//  BRUserPreferenceDefine.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRUserPreferenceDefine.h"

#define kBackgroundImageName @"backgroundimagename"
#define kMostReadCount       @"feedsinmostread"

@implementation BRUserPreferenceDefine

+(UIImage*)backgroundImage{
    NSString* imageName = [self backgroundImageName];
#warning add code to get image from lib
    UIImage* image = [UIImage imageNamed:imageName];
    if (image == nil){
        image = [UIImage imageNamed:imageName];
    }
    
    return image;
}

+(NSInteger)mostReadCount{
    return [[self valueForIdentifier:kMostReadCount] intValue];
}

+(NSString*)backgroundImageName{
    return [self valueForIdentifier:kBackgroundImageName];
}

+(void)setDefaultBackgroundImageName:(NSString*)imageName{
    [self valueChangedForIdentifier:kBackgroundImageName value:imageName];
}

+(BOOL)shouldLoadAD{
    return YES;
}

@end
