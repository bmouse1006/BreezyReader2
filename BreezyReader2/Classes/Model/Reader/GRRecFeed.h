//
//  GRRecFeed.h
//  SmallReader
//
//  Created by Jin Jin on 10-11-3.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRBaseProtocol.h"

@interface GRRecFeed : NSObject<GRBaseProtocol>

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* snippet;
@property (nonatomic, strong) NSString* streamID;
@property (nonatomic, strong) NSString* impressionTime;

@property (nonatomic, assign) BOOL isSubscribed;

+(GRRecFeed*)recFeedsWithJSONObject:(NSDictionary*)JSONObj;

@end
