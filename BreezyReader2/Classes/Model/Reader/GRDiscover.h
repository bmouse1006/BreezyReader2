//
//  GRDiscover.h
//  SmallReader
//
//  Created by Jin Jin on 10-10-28.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRBaseProtocol.h"

typedef enum{
	GRDiscoverTypeRecFeeds,
	GRDiscoverTypeRecItems,
	GRDiscoverTypeSearchFeeds,
	GRDiscoverTypeAddNewFeed
} GRDiscoverType;

@interface GRDiscover : NSObject<GRBaseProtocol> 

@property (nonatomic, readonly) GRDiscoverType type;
@property (nonatomic, strong) NSString* string;
@property (nonatomic, strong) UIImage* theIcon;
@property (nonatomic, readonly, getter=unreadCount) NSInteger unread;

-(id)initWithGRDiscoverType:(GRDiscoverType)mType;

@end
