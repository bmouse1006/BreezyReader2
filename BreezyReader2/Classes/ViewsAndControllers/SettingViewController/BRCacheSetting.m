//
//  BRCacheSetting.m
//  BreezyReader2
//
//  Created by Jin Jin on 12-5-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRCacheSetting.h"

@implementation BRCacheSetting

@synthesize viewController = _viewController;

-(NSInteger)numberOfRowsInSection{
    return 2;
}

-(id)tableView:(UITableView*)tableView cellForRow:(NSInteger)index{
    return [[[UITableViewCell alloc] init] autorelease];
}

-(NSString*)sectionTitle{
    return NSLocalizedString(@"title_cache", nil);
}


@end
