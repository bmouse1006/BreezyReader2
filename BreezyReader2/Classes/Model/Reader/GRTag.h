//
//  GRTag.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRBaseProtocol.h"
#import "GRSubscription.h"

#define NOLABEL @"BR_nolabel"

@interface GRTag : NSObject<GRBaseProtocol, NSCoding> 

@property (nonatomic, retain) NSString* ID;
@property (nonatomic, retain) NSString* sortID;
@property (nonatomic, retain) NSString* label;
@property (nonatomic, retain) NSString* typeString;

@property (nonatomic, assign) NSInteger unreadCount;
@property (nonatomic, assign) NSTimeInterval newestItemTimestampUsec;

-(GRSubscription*)toSubscription;
-(NSString*)presentationString;
-(NSInteger)unreadCount;
-(UIImage*)icon;
-(NSString*)keyString;

-(id)initWithLabel:(NSString*)mLabel;

+(GRTag*)tagWithJSONObject:(NSDictionary*)JSONTag;
+(GRTag*)tagWithNoLabel;

@end
