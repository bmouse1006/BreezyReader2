//
//  BRSubFavoritePageController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRSubFavoritePageController.h"

@interface BRSubFavoritePageController ()

@end

@implementation BRSubFavoritePageController

-(id<UITableViewDataSource>)generateDataSourceWithMediaSource:(id<JJMediaSource>)source{
    BRSubGridViewDataSource* datasource = [[[BRSubGridViewDataSource alloc] initWithMediaSource:source delegate:self] autorelease];
    [datasource setThumbSize:[self thumbSize] thumbSpacing:[self thumbSpacing]];
    return datasource;
}

@end
