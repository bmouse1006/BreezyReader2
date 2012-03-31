//
//  FeedSearchDataSource.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRSearchDataSource.h"
#import "ASIHTTPRequest.h"

@interface FeedSearchDataSource : BRSearchDataSource<ASIHTTPRequestDelegate>

-(NSString*)title;

@end
