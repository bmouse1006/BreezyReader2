//
//  BRAccountSetting.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRAccountSetting.h"

@implementation BRAccountSetting

-(NSInteger)numberOfRowsInSection{
    return 2;
}

-(id)tableView:(UITableView*)tableView cellForRow:(NSInteger)index{
    return [[[UITableViewCell alloc] init] autorelease];
}

-(NSString*)sectionTitle{
    return NSLocalizedString(@"title_accounts", nil);
}

@end
