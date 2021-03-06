//
//  GRSubscription.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GRSubscription.h"
#import "GRTag.h"

@implementation GRSubscription

@synthesize ID = _ID;
@synthesize title = _title;
@synthesize sortID = _sortID;
@synthesize firstItemMSec = _firstItemMSec;
@synthesize categories = _categories;
@synthesize downloadedDate = _downloadedDate;

@synthesize unreadCount = _unreadCount;
@synthesize newestItemTimestampUsec = _newestItemTimestampUsec;
@synthesize isUnreadOnly;

@synthesize firstItemDate = _firstItemDate;
@synthesize newestItemDate = _newestItemDate;

-(BOOL)isEqual:(id)object{
	BOOL equal = NO;
	
	if ([object isKindOfClass:[GRSubscription class]]){
		GRSubscription* obj = object;
		equal = [self.ID isEqualToString:obj.ID];
	}
	
	return equal;
}

-(void)setNewestItemTimestampUsec:(NSTimeInterval)newestItemTimestampUsec{
    _newestItemTimestampUsec = newestItemTimestampUsec;
    _newestItemDate = [NSDate dateWithTimeIntervalSince1970:_newestItemTimestampUsec/1000000];
}

-(void)setFirstItemMSec:(NSTimeInterval)firstItemMSec{
    _firstItemMSec = firstItemMSec;
    _firstItemDate = [NSDate dateWithTimeIntervalSince1970:firstItemMSec/1000];
}

-(NSString*)keyString{
	NSString* tail;
	if (isUnreadOnly){
		tail = @"_unread";
	}else {
		tail = @"_all";
	}

	return [self.ID stringByAppendingString:tail];
}

-(NSString*)presentationString{
	return self.title;
}

-(NSArray*)keysForLabels{
    NSMutableArray* keys = [NSMutableArray array];
    [self.categories enumerateObjectsUsingBlock:^(id obj, BOOL* stop){
        NSString* key = obj;
        if ([key hasPrefix:@"label/"]){
            [keys addObject:key];
        }
    }];
    
    return keys;
}

-(UIImage*)icon{
	static NSString* DefaultIconName = @"text.png";
	
	UIImage* image = nil;
	NSString* imageName = [self.title stringByAppendingString:@".png"];
	image = [UIImage imageNamed:imageName];
	
	if (!image){
		image = [UIImage imageNamed:DefaultIconName];
	}
	
	return image;
}

-(GRRecFeed*)recFeedFromSubscription{
	GRRecFeed* feed = [[GRRecFeed alloc] init];
	feed.streamID = self.ID;
	feed.title = self.title;
	
	return feed;
}

-(BOOL)isStream{
    return [self.ID hasPrefix:@"feed/"];
}

+(GRSubscription*)subscriptionWithJSONObject:(NSDictionary*)JSONSub{

	if (![JSONSub isKindOfClass:[NSDictionary class]]){
		return nil;
	}
	
	GRSubscription* newSub = [[GRSubscription alloc] init];
	
	newSub.ID = [JSONSub objectForKey:@"id"];
	newSub.title = [JSONSub objectForKey:@"title"];
	newSub.sortID = [JSONSub objectForKey:@"sortid"];
	newSub.firstItemMSec = [[JSONSub objectForKey:@"firstitemmsec"] doubleValue];
    
    for (NSDictionary* dic in [JSONSub objectForKey:@"categories"]){
        [newSub.categories addObject:[dic objectForKey:@"id"]];
    }
	
	return newSub;

}

+(GRSubscription*)subscriptionForAllItems{
    
	GRSubscription* allItems = [self subscriptionForLabel:@"user/-/state/com.google/reading-list"];
	allItems.title = @"reading-list";
	return allItems;
}

+(GRSubscription*)subscriptionForUnread{
    GRSubscription* unread = [self subscriptionForLabel:@"user/-/state/com.google/reading-list?xt=user/-/state/com.google/read"];
    unread.title = @"unread";
    return unread;
}

+(GRSubscription*)subscriptionForLabel:(NSString*)label{
	GRSubscription* allItems = [[GRSubscription alloc] init];
	allItems.ID = label;
    allItems.title = label;
	allItems.sortID = @"000000";
	return allItems;
}

+(GRSubscription*)subscriptionForGRRecFeed:(GRRecFeed*)recFeed{
	GRSubscription* recSub = [[GRSubscription alloc] init];
	recSub.ID = recFeed.streamID;
	recSub.title = recFeed.title;
	recSub.sortID = @"000000";
	return recSub;
}

-(id)init{
	if (self = [super init]){
		self.categories = [NSMutableSet setWithCapacity:0];
		self.ID = nil;
		self.sortID = nil;
		self.title = nil;
		self.newestItemTimestampUsec = 0;
        self.firstItemMSec = 0;
		self.unreadCount = 0;
	}
	return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self){
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.sortID = [aDecoder decodeObjectForKey:@"sortID"];
        self.categories = [aDecoder decodeObjectForKey:@"categories"];
        self.newestItemTimestampUsec = [[aDecoder decodeObjectForKey:@"newestItemTimestampUsec"] doubleValue];
        self.firstItemMSec = [[aDecoder decodeObjectForKey:@"firstItemMSec"] doubleValue];
        self.unreadCount = [[aDecoder decodeObjectForKey:@"unreadCount"] intValue];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.sortID forKey:@"sortID"];
    [aCoder encodeObject:self.categories forKey:@"categories"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.newestItemTimestampUsec] forKey:@"newestItemTimestampUsec"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.firstItemMSec] forKey:@"firstItemMSec"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.unreadCount] forKey:@"unreadCount"];
}

@end
