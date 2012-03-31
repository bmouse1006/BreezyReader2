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

@property (nonatomic, retain) NSString * ID;
@property (nonatomic, retain) NSString * sortID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * downloadedDate;
@property (nonatomic, retain) NSNumber * newestItemTimestampUsec;
//
//@property (nonatomic, readonly, getter=getDownloadedDuration) NSString* downloadedDuration;

-(void)setGRSub:(GRSubscription*)sub;
-(GRSubscription*)GRSub;

@end



