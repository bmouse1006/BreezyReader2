//
//  GRSearchResult.h
//  BreezyReader2
//
//  Created by 金 津 on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GRSearchResult : NSObject

@property (nonatomic, strong) NSDictionary* JSONObj;
@property (weak, nonatomic, readonly, getter = getResults) NSArray* results;
@property (weak, nonatomic, readonly, getter = getQuery) NSString* query;
@property (weak, nonatomic, readonly, getter = getCategoryid) NSString* categoryid;
@property (nonatomic, readonly, getter = getHaspreviouspage) BOOL haspreviouspage;
@property (nonatomic, readonly, getter = getPreviouspagestart) NSInteger previouspagestart;
@property (nonatomic, readonly, getter = getHasnextpage) BOOL hasnextpage;
@property (nonatomic, readonly, getter = getNextpagestart) NSInteger nextpagestart;

+(GRSearchResult*)resultWithJSONObj:(NSDictionary*)JSONObj;

@end
