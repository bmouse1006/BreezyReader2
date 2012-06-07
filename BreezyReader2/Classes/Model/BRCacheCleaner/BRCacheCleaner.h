//
//  BRCacheCleaner.h
//  BreezyReader2
//
//  Created by Jin Jin on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRCacheCleaner : NSObject

+(id)sharedCleaner;

-(void)clearHTTPResponseCacheBeforeDate:(NSDate*)date;

@end
