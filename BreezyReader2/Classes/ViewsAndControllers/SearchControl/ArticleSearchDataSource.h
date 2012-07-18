//
//  ArticleSearchDataSource.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRSearchDataSource.h"
#import "GRFeed.h"

@interface ArticleSearchDataSource : BRSearchDataSource 

-(NSString*)title;
@property (nonatomic, strong) GRFeed* feed;

@end
