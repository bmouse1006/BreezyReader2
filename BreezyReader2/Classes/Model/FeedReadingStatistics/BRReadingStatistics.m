//
//  BRReadingStatistics.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define kFirstReadTimestamp @"kFirstReadTimestamp"
#define kReadingCount @"kReadingCount"

#import "BRReadingStatistics.h"

@interface BRReadingStatistics()

-(double)readingFrequencyForFeed:(NSString*)ID;
-(void)persistent;

@end

@implementation BRReadingStatistics

static NSMutableDictionary* _firstReadTimestamp = nil;
static NSMutableDictionary* _readingCount = nil;

+(id)statistics{
    return [[[self alloc] init] autorelease];
}

-(NSMutableDictionary*)firstReadTimestamp{
    if (_firstReadTimestamp == nil){
        _firstReadTimestamp = [[NSUserDefaults standardUserDefaults] objectForKey:kFirstReadTimestamp];
        if (_firstReadTimestamp == nil){
            _firstReadTimestamp = [[NSMutableDictionary alloc] init];
        }
    }
    
    return _firstReadTimestamp;
}

-(NSMutableDictionary*)readingCount{
    if (_readingCount == nil){
        _readingCount = [[NSUserDefaults standardUserDefaults] objectForKey:kReadingCount];
        if (_readingCount == nil){
            _readingCount = [[NSMutableDictionary alloc] init];
        }
    }
    
    return _readingCount;
}

-(NSArray*)sortedSubscriptionsByReadingFrequency:(NSArray*)subscriptions{
    return [subscriptions sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        double frequency1 = [self readingFrequencyForFeed:[obj1 performSelector:@selector(ID)]]; 
        double frequency2 = [self readingFrequencyForFeed:[obj2 performSelector:@selector(ID)]]; 
        NSComparisonResult result = NSOrderedSame;
        if (frequency1 > frequency2){
            result = NSOrderedAscending;
        }else if (frequency1 == frequency2){
            result = NSOrderedSame;
        }else if (frequency1 < frequency2){
            result = NSOrderedDescending;
        }
        return result;
    }];
}

-(void)readFeed:(NSString*)ID{
    if ([[self firstReadTimestamp] objectForKey:ID] == nil){
        [[self firstReadTimestamp] setObject:[NSDate date] forKey:ID];
    }
    
    NSNumber* count = [[self readingCount] objectForKey:ID];
    if (count == nil){
        count = [NSNumber numberWithInt:0];
    }
    
    count = [NSNumber numberWithInt:[count intValue]+1];
    
    [[self readingCount] setObject:count forKey:ID];
    
    NSLog(@"%@ is read %d times", ID, [count intValue]);
    NSLog(@"frequency is %.2f", [self readingFrequencyForFeed:ID]);

    [self persistent];
}

-(double)readingFrequencyForFeed:(NSString*)ID{
    
    NSDate* firstRead = [[self firstReadTimestamp] objectForKey:ID];
    if (firstRead == nil){
        return 0;
    }
    
    NSNumber* readCount = [[self readingCount] objectForKey:ID];
    
    NSInteger days = ((NSInteger)[[NSDate date] timeIntervalSinceDate:firstRead])/((NSInteger)(3600*24))+1;
    return [readCount doubleValue]/days;
}

-(NSUInteger)countOfRecordedReadingFrequency{
    return [[self firstReadTimestamp] count];
}

-(NSArray*)mostReadSubscriptionIDsCount:(NSInteger)count{
    NSArray* keys = [[self firstReadTimestamp] allKeys];
    NSArray* sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        double frequency1 = [self readingFrequencyForFeed:obj1]; 
        double frequency2 = [self readingFrequencyForFeed:obj2]; 
        NSComparisonResult result = NSOrderedSame;
        if (frequency1 > frequency2){
            result = NSOrderedAscending;
        }else if (frequency1 == frequency2){
            result = NSOrderedSame;
        }else if (frequency1 < frequency2){
            result = NSOrderedDescending;
        }
        return result;
    }];
    
    count = MIN([sortedKeys count], count);
    NSRange range = {0, count};
    return [sortedKeys subarrayWithRange:range];
}

-(void)persistent{
    [[NSUserDefaults standardUserDefaults] setObject:[self readingCount] forKey:kReadingCount];
    [[NSUserDefaults standardUserDefaults] setObject:[self firstReadTimestamp] forKey:kFirstReadTimestamp];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
