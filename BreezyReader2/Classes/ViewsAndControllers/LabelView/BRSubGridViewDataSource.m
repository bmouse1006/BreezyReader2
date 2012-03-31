//
//  BRSubGridViewDataSource.m
//  BreezyReader2
//
//  Created by 金 津 on 12-2-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRSubGridViewDataSource.h"
#import "BRSubscriptionTileView.h"

@implementation BRSubGridViewDataSource

-(Class)classForThumbnail{
    return [BRSubscriptionTileView class];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

@end
