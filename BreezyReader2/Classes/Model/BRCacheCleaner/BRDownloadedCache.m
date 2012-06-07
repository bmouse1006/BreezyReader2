//
//  BRDownloadedCache.m
//  BreezyReader2
//
//  Created by Jin Jin on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRDownloadedCache.h"

#define sessionCacheFolder @"SessionStore"
#define permanentCacheFolder @"PermanentStore"

@implementation BRDownloadedCache

-(void)clearCachedResponsesForStoragePolicy:(ASICacheStoragePolicy)storagePolicy beforeDate:(NSDate*)date{
	[[self accessLock] lock];
	if (![self storagePath]) {
		[[self accessLock] unlock];
		return;
	}
	NSString *path = [[self storagePath] stringByAppendingPathComponent:(storagePolicy == ASICacheForSessionDurationCacheStoragePolicy ? sessionCacheFolder : permanentCacheFolder)];
    
	NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    
	BOOL isDirectory = NO;
	BOOL exists = [fileManager fileExistsAtPath:path isDirectory:&isDirectory];
	if (!exists || !isDirectory) {
		[[self accessLock] unlock];
		return;
	}
	NSError *error = nil;
	NSArray *cacheFiles = [fileManager contentsOfDirectoryAtPath:path error:&error];
	if (error) {
		[[self accessLock] unlock];
		[NSException raise:@"FailedToTraverseCacheDirectory" format:@"Listing cache directory failed at path '%@'",path];	
	}
	for (NSString *file in cacheFiles) {
        //get time stamp
        NSDictionary* attributes = [fileManager attributesOfItemAtPath:[path stringByAppendingPathComponent:file] error:&error];
        if (error) {
			[[self accessLock] unlock];
			[NSException raise:@"FailedToRemoveCacheFile" format:@"Failed to remove cached data at path '%@'",path];
		}
        
        NSDate* modifiedDate = [attributes objectForKey:NSFileModificationDate];
        
        if ([modifiedDate compare:date] == NSOrderedAscending){
            //modifiedDate is earlier than date
            [fileManager removeItemAtPath:[path stringByAppendingPathComponent:file] error:&error];
            if (error) {
                [[self accessLock] unlock];
                [NSException raise:@"FailedToRemoveCacheFile" format:@"Failed to remove cached data at path '%@'",path];
            }
        }
	}
	[[self accessLock] unlock];
}

@end
