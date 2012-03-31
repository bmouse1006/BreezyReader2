// 
//  GRSubModel.m
//  BreezyReader
//
//  Created by Jin Jin on 10-8-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GRSubModel.h"


@implementation GRSubModel 

@dynamic ID;
@dynamic sortID;
@dynamic title;
@dynamic downloadedDate;
@dynamic newestItemTimestampUsec;

-(void)setGRSub:(GRSubscription*)sub{
	[sub retain];
//	[self setValue:sub.ID forKey:@"ID"];
//	[self setValue:sub.sortID forKey:@"sortID"];
//	[self setValue:sub.title forKey:@"title"];
//	[self setValue:sub.downloadedDate forKey:@"downloadedDate"];
//	[self setValue:[NSNumber numberWithDouble:sub.newestItemTimestampUsec] forKey:@"newestItemTimestampUsec"];
	
	self.ID = sub.ID;
	self.sortID = sub.sortID;
	self.title = sub.title;
	self.downloadedDate = sub.downloadedDate;
	self.newestItemTimestampUsec = [NSNumber numberWithDouble:sub.newestItemTimestampUsec];
	
	[sub release];
}

-(GRSubscription*)GRSub{
	GRSubscription* sub = [[GRSubscription alloc] init];
	
//	sub.ID = [self valueForKey:@"ID"];
//	sub.sortID = [self valueForKey:@"sortID"];
//	sub.title = [self valueForKey:@"title"];
//	sub.downloadedDate = [self valueForKey:@"downloadedDate"];
//	sub.newestItemTimestampUsec = [(NSNumber*)[self valueForKey:@"newestItemTimestampUsec"] doubleValue];
//	
	sub.ID = self.ID;
	sub.sortID = self.sortID;
	sub.title = self.title;
	sub.downloadedDate = self.downloadedDate;
	sub.newestItemTimestampUsec = [self.newestItemTimestampUsec doubleValue];
	
	return [sub autorelease];
}

-(NSString*)getDownloadedDuration{
	return nil;
}

-(id)init{
	if (self = [super init]){
		[self setValue:[NSDate distantPast] forKey:@"downloadedDate"];
	}
	
	return self;
}

@end
