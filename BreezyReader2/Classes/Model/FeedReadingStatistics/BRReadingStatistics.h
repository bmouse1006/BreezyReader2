//
//  BRReadingStatistics.h
//  BreezyReader2
//
//  Created by 金 津 on 12-4-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRReadingStatistics : NSObject

+(id)statistics;

-(NSArray*)sortedSubscriptionsByReadingFrequency:(NSArray*)subscriptions;
-(void)readFeed:(NSString*)ID;
-(void)refreshFeed:(NSString*)ID;
-(NSTimeInterval)lastRefreshedTimestampOfFeed:(NSString*)ID;

-(NSUInteger)countOfRecordedReadingFrequency;

-(NSArray*)mostReadSubscriptions:(NSInteger)count;

@end
