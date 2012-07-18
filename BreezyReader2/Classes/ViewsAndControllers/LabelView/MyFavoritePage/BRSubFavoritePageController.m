//
//  BRSubFavoritePageController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRSubFavoritePageController.h"
#import "BRSubFavoriteSource.h"

@interface BRSubFavoritePageController ()

@end

@implementation BRSubFavoritePageController

-(void)createSource{
    self.source = [[BRSubFavoriteSource alloc] init];
    self.source.delegate = self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
}

@end
