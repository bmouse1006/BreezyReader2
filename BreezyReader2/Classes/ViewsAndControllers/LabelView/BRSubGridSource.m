//
//  BRSubGridSource.m
//  BreezyReader2
//
//  Created by 金 津 on 12-2-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRSubGridSource.h"
#import "GRDataManager.h"
#import "BRReadingStatistics.h"

@implementation BRSubGridSource

@synthesize tag = _tag, subscriptions = _subscriptions;
@synthesize delegate = _delegate;

-(void)dealloc{
    self.tag = nil;
    self.subscriptions = nil;
    self.delegate = nil;
    [super dealloc];
}

-(NSString*)title{
    return self.tag.label;
}
/**
 * The total number of photos in the source, independent of the number that have been loaded.
 */
-(NSInteger)numberOfMedias{
    return [self.subscriptions count];
}

/**
 * The maximum index of photos that have already been loaded.
 */
-(NSInteger)maxMediaIndex{
    return [self numberOfMedias]-1;
}

- (id<JJMedia>)mediaAtIndex:(NSInteger)index{
    return [self.subscriptions objectAtIndex:index];
//    return nil;
}

-(void)loadSourceMore:(BOOL)more{
    [self.delegate sourceStartLoading];
    NSArray* subscriptions = [[GRDataManager shared] getSubscriptionListWithTag:self.tag.ID];
    self.subscriptions = [[BRReadingStatistics statistics] sortedSubscriptionsByReadingFrequency:subscriptions];
    [self.delegate sourceLoadFinished];
}

@end
