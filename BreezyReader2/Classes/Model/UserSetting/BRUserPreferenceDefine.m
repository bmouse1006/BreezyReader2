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
#define kDefaultBackgroundImageName @"background1.jpg"

@implementation BRUserPreferenceDefine



+(NSURL*)backgroundImageURL{
    
    NSString* cachePath = [[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"backgroundCache"] retain];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDictionary = NO;
    if ([fm fileExistsAtPath:cachePath isDirectory:&isDictionary] == NO){
        [fm createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    
    NSString* compelePath = [cachePath stringByAppendingPathComponent:@"defaultbackground.png"];
    
    return [NSURL fileURLWithPath:compelePath];
}

+(UIImage*)backgroundImage{
    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[self backgroundImageURL]]];
    
    if (!image){
        image = [UIImage imageNamed:kDefaultBackgroundImageName];
        [self setDefaultBackgroundImage:image withName:kDefaultBackgroundImageName];
    }
    
    return image;
}

+(void)setDefaultBackgroundImage:(UIImage*)image withName:(NSString*)name{
    [[NSFileManager defaultManager] removeItemAtURL:[self backgroundImageURL] error:NULL];
    [UIImagePNGRepresentation(image) writeToURL:[self backgroundImageURL] atomically:YES];
    [self valueChangedForIdentifier:name value:kBackgroundImageName];
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
