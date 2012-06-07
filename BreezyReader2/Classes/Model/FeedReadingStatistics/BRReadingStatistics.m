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
#import "GoogleReaderClient.h"

@interface BRReadingStatistics()

-(double)readingFrequencyForFeed:(NSString*)ID;
-(void)persistent;

@end

@implementation BRReadingStatistics

+(id)statistics{
    return [[[self alloc] init] autorelease];
}

-(NSMutableDictionary*)firstReadTimestamps{
    static dispatch_once_t firstToken;
    static NSMutableDictionary* _firstReadTimestamp = nil;
    dispatch_once(&firstToken, ^{
        _firstReadTimestamp = [[NSUserDefaults standardUserDefaults] objectForKey:kFirstReadTimestamp];
        if (_firstReadTimestamp == nil){
            _firstReadTimestamp = [[NSMutableDictionary alloc] init];
        }
    });
    
    return _firstReadTimestamp;
}

-(NSMutableDictionary*)lastReadTimestamps{
    static dispatch_once_t lastToken;
    static NSMutableDictionary* _lastReadTimestamp = nil;
    dispatch_once(&lastToken, ^{
        _lastReadTimestamp = [[NSUserDefaults standardUserDefaults] objectForKey:kFirstReadTimestamp];
        if (_lastReadTimestamp == nil){
            _lastReadTimestamp = [[NSMutableDictionary alloc] init];
        }
    });

    return _lastReadTimestamp;
}

-(NSMutableDictionary*)readingCounts{
    static dispatch_once_t readingCountToken;
    static NSMutableDictionary* _readingCount = nil;
    dispatch_once(&readingCountToken, ^{
        _readingCount = [[NSUserDefaults standardUserDefaults] objectForKey:kReadingCount];
        if (_readingCount == nil){
            _readingCount = [[NSMutableDictionary alloc] init];
        }
    });

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
    if ([[self firstReadTimestamps] objectForKey:ID] == nil){
        [[self firstReadTimestamps] setObject:[NSDate date] forKey:ID];
    }
    
    //record last read time stamp
    [[self lastReadTimestamps] setObject:[NSDate date] forKey:ID];
    
    NSNumber* count = [[self readingCounts] objectForKey:ID];
    if (count == nil){
        count = [NSNumber numberWithInt:0];
    }
    
    count = [NSNumber numberWithInt:[count intValue]+1];
    
    [[self readingCounts] setObject:count forKey:ID];
    
    NSLog(@"%@ is read %d times", ID, [count intValue]);
    NSLog(@"frequency is %.2f", [self readingFrequencyForFeed:ID]);

    [self persistent];
}

-(double)readingFrequencyForFeed:(NSString*)ID{
    
    NSDate* firstRead = [[self firstReadTimestamps] objectForKey:ID];
    if (firstRead == nil){
        return 0;
    }
    
    NSNumber* readCount = [[self readingCounts] objectForKey:ID];
    
    NSInteger days = ((NSInteger)[[NSDate date] timeIntervalSinceDate:firstRead])/((NSInteger)(3600*24))+1;
    return [readCount doubleValue]/days;
}

-(NSUInteger)countOfRecordedReadingFrequency{
    return [[self firstReadTimestamps] count];
}

-(NSArray*)mostReadSubscriptions:(NSInteger)count{
    NSArray* keys = [[self firstReadTimestamps] allKeys];
    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary* bingdings){
        if ([GoogleReaderClient containsSubscription:evaluatedObject]){
            return YES;
        }
        return NO;
    }];
    NSArray* availableKeys = [keys filteredArrayUsingPredicate:predicate];
    NSArray* sortedKeys = [availableKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
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
    [[NSUserDefaults standardUserDefaults] setObject:[self readingCounts] forKey:kReadingCount];
    [[NSUserDefaults standardUserDefaults] setObject:[self firstReadTimestamps] forKey:kFirstReadTimestamp];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSTimeInterval)lastReadTimestampOfFeed:(NSString*)ID{
    NSDate* lastRead = [[self lastReadTimestamps] objectForKey:ID];
    if (lastRead == nil){
        lastRead = [NSDate distantPast];
    }
    
    return [lastRead timeIntervalSince1970];
}

@end
