//
//  BRUserPreferenceDefine.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRUserPreferenceDefine.h"
#import "UIImage+addition.h"
#import "GoogleReaderClient.h"
#import "GPUImage.h"

#define kSwipeLeftAction @"swipeLeftAction"
#define kSwipeRightAction @"swipeRightAction"
#define kBackgroundImageName @"backgroundimagename"
#define kMostReadCount       @"feedsinmostread"
#define kAutoFlipThumbnail   @"animateflipview"
#define kSortByReadingFrequency @"sortingbyreadingfrequency"
#define kShowRecommendations @"showrecommendations"
#define kAutoRotateImage @"autorotateimage"
#define kRememberMyAction @"rememberMyChoice"
#define kShowUnreadOnly @"shouldShowUnreadOnly"
#define kAutoClearCache @"autoclearcache"
#define kUnreadOnlySet @"unreadOnlySet"
#define kBlurBackgroundImage @"blurBackgroundImage"

#define kDefaultBackgroundImageName @"background1.jpg"

@implementation BRUserPreferenceDefine

static UIImage* _backgroundImage = nil;
static UIImage* _blurBackgroundImage = nil;

+(UIColor*)flipThumbnailColor{
//    return [UIColor colorWithRed:26/255.0 green:78/255.0 blue:138/255.0 alpha:0.6];
//    return [UIColor colorWithRed:154/255.0 green:205/255.0 blue:244/255.0 alpha:0.6];
//    return [UIColor colorWithRed:12/255.0 green:65/255.0 blue:122/255.0 alpha:0.4];
    return [[UIColor blackColor] colorWithAlphaComponent:0.4f];
}

+(UIColor*)barColor{
    return [UIColor colorWithRed:12/255.0 green:65/255.0 blue:122/255.0 alpha:1];
}

+(NSURL*)backgroundImageStoreURL{
    
    NSString* cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"backgroundCache"];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDictionary = NO;
    if ([fm fileExistsAtPath:cachePath isDirectory:&isDictionary] == NO){
        [fm createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    
    NSString* compelePath = [cachePath stringByAppendingPathComponent:@"defaultbackground.png"];
    
    return [NSURL fileURLWithPath:compelePath];
}

+(NSURL*)blurBackgroundImageStoreURL{
    
    NSString* cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"backgroundCache"];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDictionary = NO;
    if ([fm fileExistsAtPath:cachePath isDirectory:&isDictionary] == NO){
        [fm createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    
    NSString* compelePath = [cachePath stringByAppendingPathComponent:@"blurbackground.png"];
    
    return [NSURL fileURLWithPath:compelePath];
}

+(UIImage*)backgroundImage{
    
    if (!_backgroundImage){
        UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[self backgroundImageStoreURL]]];
        
        if (!image){
            [self setDefaultBackgroundImage:[UIImage imageNamed:kDefaultBackgroundImageName] withName:kDefaultBackgroundImageName];
        }else{
            _backgroundImage = [image retain];
            _blurBackgroundImage = [[self applyBlurImage:_backgroundImage] retain];
        }
    }
    
    return ([self shouldBlurBackgroundImage])?_blurBackgroundImage:_backgroundImage;
}

+(void)setDefaultBackgroundImage:(UIImage*)image withName:(NSString*)name{
    [self valueChangedForIdentifier:kBackgroundImageName value:name];
    image = [image clippedThumbnailWithSize:[UIScreen mainScreen].bounds.size];
    UIImage* blurImage = [self applyBlurImage:image];
    
    [_backgroundImage release];
    _backgroundImage = [image retain];
    
    [_blurBackgroundImage release];
    _blurBackgroundImage = [blurImage retain];
    
    [[NSFileManager defaultManager] removeItemAtURL:[self backgroundImageStoreURL] error:NULL];
    [UIImagePNGRepresentation(image) writeToURL:[self backgroundImageStoreURL] atomically:YES];
    
    [[NSFileManager defaultManager] removeItemAtURL:[self blurBackgroundImageStoreURL] error:NULL];
    [UIImagePNGRepresentation(blurImage) writeToURL:[self blurBackgroundImageStoreURL] atomically:YES];
}

#pragma mark - blur background image
+(UIImage*)applyBlurImage:(UIImage*)image{
    GPUImagePicture* sourcePicture = [[[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES] autorelease];
    GPUImageGaussianBlurFilter* blurFilter = [[[GPUImageGaussianBlurFilter alloc] init] autorelease];
    blurFilter.blurSize = 8.0f;
    
    [sourcePicture addTarget:blurFilter];
    [sourcePicture processImage];
    
    return [blurFilter imageFromCurrentlyProcessedOutput];
}

+(NSInteger)mostReadCount{
    return [[self valueForIdentifier:kMostReadCount] intValue];
}

+(NSString*)backgroundImageName{
    return [self valueForIdentifier:kBackgroundImageName];
}

+(NSString*)notificationNameForSwipeRightAction{
    return [self valueForIdentifier:kSwipeRightAction];
}

+(NSString*)notificationNameForSwipeLeftAction{
    return [self valueForIdentifier:kSwipeLeftAction];
}

+(void)setDefaultBackgroundImageName:(NSString*)imageName{
    [self valueChangedForIdentifier:kBackgroundImageName value:imageName];
}

+(BOOL)shouldBlurBackgroundImage{
    return [self boolValueForIdentifier:kBlurBackgroundImage];
}

+(BOOL)autoClearCache{
    return [self boolValueForIdentifier:kAutoClearCache];
}

+(BOOL)shouldLoadAD{
    return NO;
}

+(BOOL)shouldAutoFlipThumbnail{
    return [self boolValueForIdentifier:kAutoFlipThumbnail];
}

+(BOOL)shouldSortByReadingFrequency{
    return [self boolValueForIdentifier:kSortByReadingFrequency];
}

+(BOOL)shouldShowRecommendations{
    return [self boolValueForIdentifier:kShowRecommendations];
}

+(BOOL)shouldShowUnreadOnly{
    return [self boolValueForIdentifier:kShowUnreadOnly];
}

+(BOOL)shouldRememberMyActionWhileShowingArticles{
    return [self boolValueForIdentifier:kRememberMyAction];
}

+(BOOL)shouldAutoRotateImage{
    return [self boolValueForIdentifier:kAutoRotateImage];
}

+(BOOL)unreadOnlyStatusForStream:(NSString*)streamID{
    //check if this sub has been subscribed
    if ([GoogleReaderClient containsSubscription:streamID] == NO){
        return NO;
    }
    
    if ([self shouldRememberMyActionWhileShowingArticles]){
        
        NSNumber* action = [[self valueForIdentifier:kUnreadOnlySet] objectForKey:streamID];
        
        if (action){
            return [action boolValue];
        }else{
            return [self shouldShowUnreadOnly];
        }
    
    }else{
        return [self shouldShowUnreadOnly];
    }
}

+(void)rememberAction:(BOOL)unreadOnly forStream:(NSString*)streamID{
    if ([self shouldRememberMyActionWhileShowingArticles]){
        NSMutableDictionary* unreadonlySet = [NSMutableDictionary dictionaryWithDictionary:[self valueForIdentifier:kUnreadOnlySet]];
        
        [unreadonlySet setObject:[NSNumber numberWithBool:unreadOnly] forKey:streamID];
        
        [self valueChangedForIdentifier:kUnreadOnlySet value:unreadonlySet];
    }
}

@end
