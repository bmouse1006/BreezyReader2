//
//  GRSubModel.h
//  BreezyReader
//
//  Created by Jin Jin on 10-8-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "GRSubscription.h"

@interface GRSubModel :  NSManagedObject

@property (nonatomic, strong) NSString * ID;
@property (nonatomic, strong) NSString * sortID;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSDate * downloadedDate;
@property (nonatomic, strong) NSNumber * newestItemTimestampUsec;
//
//@property (nonatomic, readonly, getter=getDownloadedDuration) NSString* downloadedDuration;

-(void)setGRSub:(GRSubscription*)sub;
-(GRSubscription*)GRSub;

@end



