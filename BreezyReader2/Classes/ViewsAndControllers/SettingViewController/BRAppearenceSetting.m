//
//  BRAppearenceSetting.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRAppearenceSetting.h"

@implementation BRAppearenceSetting

-(NSInteger)numberOfRowsInSection{
    return 2;
}

-(id)tableView:(UITableView*)tableView cellForRow:(NSInteger)index{
    return [[[UITableViewCell alloc] init] autorelease];
}

-(NSString*)sectionTitle{
    return NSLocalizedString(@"title_appearence", nil);
}

@end
