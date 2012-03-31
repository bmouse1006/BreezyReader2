//
//  GRSearchResultItem.h
//  BreezyReader2
//
//  Created by 金 津 on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GRSearchResultItem : NSObject

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* streamid;
@property (nonatomic, assign) BOOL issubscribed; 

+(GRSearchResultItem*)itemWithJSONObj:(NSDictionary*)JSONObj;

@end
