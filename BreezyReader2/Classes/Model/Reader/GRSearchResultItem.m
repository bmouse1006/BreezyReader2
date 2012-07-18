//
//  GRSearchResultItem.m
//  BreezyReader2
//
//  Created by 金 津 on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GRSearchResultItem.h"

@implementation GRSearchResultItem

@synthesize title = _title,
            streamid = _streamid,
issubscribed = _issubscribed;

+(GRSearchResultItem*)itemWithJSONObj:(NSDictionary*)JSONObj{
    GRSearchResultItem* item = [[GRSearchResultItem alloc] init];
    item.title = [JSONObj objectForKey:@"title"];
    item.streamid = [JSONObj objectForKey:@"streamid"];
    item.issubscribed = [[JSONObj objectForKey:@"issubscribed"] boolValue];
    
    return item;
}


@end
