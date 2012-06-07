//
//  BRDownloadedCache.h
//  BreezyReader2
//
//  Created by Jin Jin on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ASIDownloadCache.h"

@interface BRDownloadedCache : ASIDownloadCache

-(void)clearCachedResponsesForStoragePolicy:(ASICacheStoragePolicy)storagePolicy beforeDate:(NSDate*)date;

@end
