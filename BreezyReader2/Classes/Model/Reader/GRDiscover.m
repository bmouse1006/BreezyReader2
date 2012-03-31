//
//  GRDiscover.m
//  SmallReader
//
//  Created by Jin Jin on 10-10-28.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import "GRDiscover.h"

#define RECOMMENDEDFEEDS @"recommendedFeeds"
#define RECOMMENDEDITEMS @"recommendedItems"
#define SEARCHFEEDS		 @"searchFeeds"
#define ADDNEWFEED		 @"addNewFeed"

@implementation GRDiscover

@synthesize type = _type;
@synthesize theIcon = _theIcon;
@synthesize string = _string;
//the main string that display in table view
-(NSString*)presentationString{
	return self.string;
}

-(NSString*)ID{
	return @"999999999";
}

-(UIImage*)icon{
	return self.theIcon;
}

-(NSInteger)unreadCount{
	return 0;
}

-(id)initWithGRDiscoverType:(GRDiscoverType)mType{
	if (self = [super init]){
		_type = mType;
		switch (self.type) {
			case GRDiscoverTypeRecFeeds:
				self.string = RECOMMENDEDFEEDS;
				break;
			case GRDiscoverTypeRecItems:
				self.string = RECOMMENDEDITEMS;
				break;
			case GRDiscoverTypeSearchFeeds:
				self.string = SEARCHFEEDS;
				break;
			case GRDiscoverTypeAddNewFeed:
				self.string = ADDNEWFEED;
			default:
				break;
		}
		self.theIcon = [UIImage imageNamed:[self.string stringByAppendingString:@".png"]];
	}
	
	return self;
}

-(void)dealloc{
	self.theIcon = nil;
	self.string = nil;
	[super dealloc];
}

@end
