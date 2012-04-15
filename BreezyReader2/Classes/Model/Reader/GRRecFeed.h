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

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* snippet;
@property (nonatomic, retain) NSString* streamID;
@property (nonatomic, retain) NSString* impressionTime;

@property (nonatomic, assign) BOOL isSubscribed;

+(GRRecFeed*)recFeedsWithJSONObject:(NSDictionary*)JSONObj;

@end
