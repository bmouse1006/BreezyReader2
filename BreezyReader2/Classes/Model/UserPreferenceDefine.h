//
//  UserPreferenceDefine.h
//  BreezyReader
//
//  Created by Jin Jin on 10-7-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserPreferenceDefine : NSObject
{
	
}

+(void)valueChangedForKey:(NSString*)key value:(id)value;

+(void)resetPreference;

+(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

+(BOOL)shouldAutoHideSubAndTagWithNoNewItems;

+(BOOL)shouldUseSSLConnection;

+(BOOL)shouldShowPreviewOfArticle;

+(BOOL)shouldShowUnreadFirst;

+(BOOL)shouldTapToFullscreen;

+(BOOL)markDownloadedItemsAsRead;

+(NSUInteger)maxDownloadConcurrency;

+(NSUInteger)defaultNumberOfDownloaderItems;

+(NSDictionary*)userPreferenceBundle;

+(id)preferenceObjectForKey:(NSString*)key;

+(BOOL)boolValueForKey:(NSString*)key;

+(BOOL)iPadMode;

+(NSInteger)imageWidth;

@end