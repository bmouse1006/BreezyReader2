//
//  GRSearchResult.m
//  BreezyReader2
//
//  Created by 金 津 on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GRSearchResult.h"
#import "GRSearchResultItem.h"

@implementation GRSearchResult

@synthesize JSONObj = _JSONObj;
@synthesize results = _results, query = _query, categoryid = _categoryid, haspreviouspage = _haspreviouspage, previouspagestart = _previouspagestart, hasnextpage = _hasnextpage, nextpagestart = _nextpagestart;

+(GRSearchResult*)resultWithJSONObj:(NSDictionary*)JSONObj{
    GRSearchResult* result = [[[GRSearchResult alloc] init] autorelease];
    result.JSONObj = JSONObj;
    return result;
}

-(void)dealloc{
    self.JSONObj = nil;
    [super dealloc];
}

-(NSArray*)getResults{
    NSMutableArray* results = [NSMutableArray arrayWithCapacity:0];
    NSArray* array = [self.JSONObj objectForKey:@"results"];
    for (id obj in array){
        [results addObject:[GRSearchResultItem itemWithJSONObj:obj]];
    }
    
    return results;
}

-(NSString*)getQuery{
    return [self.JSONObj objectForKey:@"query"];
}

-(NSString*)getCategoryid{
    return [self.JSONObj objectForKey:@"categoryid"];
}

-(BOOL)getHasnextpage{
    return [[self.JSONObj objectForKey:@"hasnextpage"] boolValue];
}

-(BOOL)getHaspreviouspage{
    return [[self.JSONObj objectForKey:@"haspreviouspage"] boolValue];
}

-(NSInteger)getNextpagestart{
    return [[self.JSONObj objectForKey:@"hasnextpagestart"] intValue];
}

-(NSInteger)getPreviouspagestart{
    return [[self.JSONObj objectForKey:@"previouspagestart"] intValue];
}

@end
