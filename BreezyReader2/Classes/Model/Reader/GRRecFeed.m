//
//  GRRecFeed.m
//  SmallReader
//
//  Created by Jin Jin on 10-11-3.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import "GRRecFeed.h"


@implementation GRRecFeed

@synthesize title = _title;
@synthesize snippet = _snippet;
@synthesize streamID = _streamID;
@synthesize impressionTime = _impressionTime;
@synthesize isSubscribed;

-(NSString*)presentationString{//the main string that display in table view
	return self.title;
}

-(NSString*)ID{
	return self.streamID;
}

//-(NSString*)title;
-(UIImage*)icon{//for Subscription and Tag
	return nil;
}

+(GRRecFeed*)recFeedsWithJSONObject:(NSDictionary*)JSONObj{
	GRRecFeed* feed = [[GRRecFeed alloc] init];
	feed.title = [JSONObj objectForKey:@"title"];
	feed.snippet = [JSONObj objectForKey:@"snippet"];
	feed.streamID = [JSONObj objectForKey:@"streamId"];
	feed.impressionTime = [JSONObj objectForKey:@"impressionTime"];
	feed.isSubscribed = NO;
	
	return feed;
}


@end
