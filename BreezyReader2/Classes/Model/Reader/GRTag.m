//
//  GRTag.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GRTag.h"
#import "GoogleAppConstants.h"

@implementation GRTag

@synthesize ID = _ID;
@synthesize sortID = _sortID;
@synthesize label = _label;
@synthesize subscriptions = _subscriptions;

@synthesize unread;
@synthesize newestItemTimestampUsec;
@synthesize isUnreadOnly;

-(BOOL)isEqual:(id)object{
	BOOL equal = NO;
	
	if ([object isKindOfClass:[GRTag class]]){
		GRTag* tag = object;
		equal = [self.ID isEqualToString:tag.ID];
	}
	
	return equal;
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

-(GRSubscription*)toSubscription{
	GRSubscription* sub = [[[GRSubscription alloc] init] autorelease];
	sub.ID = self.ID;
	sub.sortID = self.sortID;
	sub.title = self.label;
	sub.unread = self.unread;
	sub.newestItemTimestampUsec = self.newestItemTimestampUsec;
	
	return sub;
}

-(NSString*)presentationString{
	return self.label;
}

-(NSInteger)unreadCount{
	return self.unread;
}

-(UIImage*)icon{
	
	static NSString* DefaultIconName = @"tag.png";
	
	UIImage* image = nil;
	NSString* imageName = [self.label stringByAppendingString:@".png"];
	image = [UIImage imageNamed:imageName];
	
	if (!image){
		image = [UIImage imageNamed:DefaultIconName];
	}
	
	return image;
}

+(GRTag*)tagWithJSONObject:(NSDictionary*)JSONTag{
	if (![JSONTag isKindOfClass:[NSDictionary class]])
		return nil;
	
	GRTag* newTag = [[[GRTag alloc] init] autorelease];
	
	newTag.ID = [JSONTag objectForKey:@"id"];
	NSArray* tokens = [newTag.ID componentsSeparatedByString:@"/"];
	newTag.label = [tokens objectAtIndex:[tokens count]-1];
	newTag.sortID = [JSONTag objectForKey:@"sortid"];
	
	return newTag;
}

-(id)init{
    self = [super init];
	if (self){
		self.subscriptions = [NSMutableSet setWithCapacity:0];
		self.ID = nil;
		self.sortID = nil;
		self.label = nil;
		newestItemTimestampUsec = 0;
		unread = 0;
		isUnreadOnly = YES;
	}
	return self;
}

-(id)initWithLabel:(NSString*)mLabel{
    self = [self init];
	if (self){
		self.label = mLabel;
		self.ID = [ATOM_PREFIX_LABEL stringByAppendingString:self.label];
	}
	
	return self;
}

-(void)dealloc{

    self.ID = nil;
    self.sortID = nil;
    self.label = nil;
    self.subscriptions = nil;
	[super dealloc];
}

@end
