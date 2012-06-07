//
//  BRCacheCleaner.m
//  BreezyReader2
//
//  Created by Jin Jin on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRCacheCleaner.h"
#import "BRDownloadedCache.h"

@implementation BRCacheCleaner

+(id)sharedCleaner{
    static dispatch_once_t onceToken;
    static BRCacheCleaner* _sharedCleaner = nil;
    dispatch_once(&onceToken, ^{
        _sharedCleaner = [[self alloc] init];
    });
    
    return _sharedCleaner;
}

-(void)clearHTTPResponseCacheBeforeDate:(NSDate*)date{
    [[BRDownloadedCache sharedCache] clearCachedResponsesForStoragePolicy:ASICachePermanentlyCacheStoragePolicy beforeDate:date];
}

@end
