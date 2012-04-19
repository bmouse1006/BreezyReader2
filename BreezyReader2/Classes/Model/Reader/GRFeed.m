//
//  GRFeed.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-7.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GRFeed.h"


@implementation GRFeed

@synthesize	generator = _generator;
@synthesize	generator_URI =_generator_URI;
@synthesize	ID =_ID;
@synthesize	selfLink =_selfLink;
@synthesize	alternateLink =_alternateLink;
@synthesize	title = _title;
@synthesize	subTitle = _subTitle;
@synthesize	gr_continuation = _gr_continuation;
@synthesize	author = _author;
@synthesize	updated = _updated;
@synthesize	published = _published;
@synthesize refreshed = _refreshed;
@synthesize items = _items;
@synthesize	sourceXML = _sourceXML;
@synthesize itemIDs = _itemIDs;
@synthesize sortArray = _sortArray;
@synthesize subscriptionID = _subscriptionID;

@synthesize imageURLs = _imageURLs;

@synthesize desc = _desc;
@synthesize direction = _direction;

-(NSArray*)imageURLs{
    if (_imageURLs == nil){
        NSMutableArray* urls = [NSMutableArray array];
        for (GRItem* item in self.items){
            [urls addObjectsFromArray:[item imageURLList]];
        }
        _imageURLs = [urls retain];
    }
    
    return _imageURLs;
}

-(NSString*)keyString{
	return self.subscriptionID;
}

-(void)sortItems{
	[self.items sortUsingDescriptors:self.sortArray];
}

-(NSString*)presentationString{
	return self.title;
}

-(GRFeed*)mergeWithFeed:(GRFeed*)feed continued:(BOOL)continued{ 
	[feed retain];
	if (feed){
		@synchronized(_items){
			self.generator = feed.generator;
			self.generator_URI = feed.generator_URI;
//			self.ID = feed.ID;
			self.selfLink = feed.selfLink;
			self.alternateLink = feed.alternateLink;
			self.title = feed.title;
			self.subTitle = feed.subTitle;
			self.author = feed.author;
//			self.updated = feed.updated;
			self.published = feed.published;
			self.refreshed = [NSDate date];
			self.sourceXML = feed.sourceXML;
			self.gr_continuation = feed.gr_continuation;
			if (continued){
				[self.items addObjectsFromArray:feed.items];
			}else {
				NSArray* tempItems = [NSArray arrayWithArray:feed.items];
				for (int i = [tempItems count] - 1	; i >= 0; i--){
					GRItem* item = [tempItems objectAtIndex:i];
					if ([self.itemIDs containsObject:item.ID]){
						[feed.items removeObjectAtIndex:i];
					}
				}
				[feed.items addObjectsFromArray:self.items];
				self.items = feed.items;
			}
			[self.itemIDs unionSet:feed.itemIDs];
            [_imageURLs release];
            _imageURLs = nil;
		}
	}
	[feed release];
	return self;
}

-(NSInteger)itemCount{
	return [self.items count];
}

-(GRItem*)getItemAtIndex:(NSUInteger)index{
	return [self.items objectAtIndex:index];
}

-(void)dealloc{

    self.generator = nil;
    self.generator_URI = nil;
    self.ID = nil;
    self.selfLink = nil;
    self.alternateLink = nil;
    self.title = nil;
    self.subTitle = nil;
    self.gr_continuation = nil;
    self.author = nil;

	self.updated = nil;
    self.published = nil;
    self.refreshed = nil;
    self.sourceXML = nil;
	
    self.items = nil;
    self.itemIDs = nil;
    
    self.sortArray = nil;
    self.subscriptionID = nil;
    
    self.desc = nil;
    self.direction = nil;
    
    [_imageURLs release];
	[super dealloc];
	
}

-(id)init{
	if (self = [super init]){
		NSSortDescriptor* tempSort1 = [[NSSortDescriptor alloc] initWithKey:@"updated" ascending:NO];
		self.sortArray = [NSArray arrayWithObjects:tempSort1, nil];
		self.items = [NSMutableArray arrayWithObjects:0];
		self.itemIDs = [NSMutableSet setWithCapacity:0];
		[tempSort1 release];
		self.refreshed = [NSDate date];
	}
	
	return self;
}

-(void)addItem:(GRItem*)item{
	//if ID of item is not in the set of item ID, than add this item to item Array
	if (![self.itemIDs containsObject:item.ID]){
		[self.itemIDs addObject:item.ID];
		[self.items addObject:item];
        [_imageURLs release];
        _imageURLs = nil;
	}
}

-(UIImage*)icon{
	return nil;
}

+(id)objWithJSON:(NSDictionary*)json{
    if ([json isKindOfClass:[NSDictionary class]] == NO){
        return nil;
    }
    GRFeed* feed = [[[self alloc] init] autorelease];
    feed.gr_continuation = [json objectForKey:@"continuation"];
    feed.desc = [json objectForKey:@"description"];
    feed.title = [json objectForKey:@"title"];
    feed.ID = [json objectForKey:@"id"];
    feed.selfLink = [[[json objectForKey:@"self"] firstObject] objectForKey:@"href"];
    feed.updated = [NSDate dateWithTimeIntervalSince1970:[[json objectForKey:@"updated"] intValue]];
    feed.direction = [json objectForKey:@"direction"];
//    feed.alternateLink = 
    NSArray* items = [json objectForKey:@"items"];
    feed.items = [NSMutableArray array];
    feed.itemIDs = [NSMutableSet set];
    for (NSDictionary* obj in items){
        GRItem* item = [GRItem objWithJSON:obj];
        [feed.items addObject:item];
        [feed.itemIDs addObject:item.ID];
    }

    return feed;
}

-(id)initWithCoder:(NSCoder*)aDecoder{
    self = [super init];
    if (self){
        self.generator = [aDecoder decodeObjectForKey:@"generator"];
        self.generator_URI = [aDecoder decodeObjectForKey:@"generator_URI"];
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
        self.selfLink = [aDecoder decodeObjectForKey:@"selfLink"];
        self.alternateLink = [aDecoder decodeObjectForKey:@"alternateLink"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.subTitle = [aDecoder decodeObjectForKey:@"subTitle"];
        self.gr_continuation = [aDecoder decodeObjectForKey:@"gr_continuation"];
        self.author = [aDecoder decodeObjectForKey:@"author"];
        
        self.updated = [aDecoder decodeObjectForKey:@"updated"];
        self.published = [aDecoder decodeObjectForKey:@"published"];
        self.refreshed = [aDecoder decodeObjectForKey:@"refreshed"];
        self.sourceXML = [aDecoder decodeObjectForKey:@"sourceXML"];
        
        self.items = [aDecoder decodeObjectForKey:@"items"];
        self.itemIDs = [aDecoder decodeObjectForKey:@"itemIDs"];
        
        self.sortArray = [aDecoder decodeObjectForKey:@"sortArray"];
        self.subscriptionID = [aDecoder decodeObjectForKey:@"subscriptionID"];
        
        self.desc = [aDecoder decodeObjectForKey:@"desc"];
        self.direction = [aDecoder decodeObjectForKey:@"direction"];
    }
            
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.generator forKey:@"generator"];
    [aCoder encodeObject:self.generator_URI forKey:@"generator_URI"];
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeObject:self.selfLink forKey:@"selfLink"];
    [aCoder encodeObject:self.alternateLink forKey:@"alternateLink"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.subTitle forKey:@"subTitle"];
    [aCoder encodeObject:self.gr_continuation forKey:@"gr_continuation"];
    [aCoder encodeObject:self.author forKey:@"author"];
    [aCoder encodeObject:self.updated forKey:@"updated"];
    [aCoder encodeObject:self.published forKey:@"published"];
    [aCoder encodeObject:self.refreshed forKey:@"refreshed"];
    [aCoder encodeObject:self.sourceXML forKey:@"sourceXML"];
    [aCoder encodeObject:self.items forKey:@"items"];
    [aCoder encodeObject:self.itemIDs forKey:@"itemIDs"];
    [aCoder encodeObject:self.sortArray forKey:@"sortArray"];
    [aCoder encodeObject:self.subscriptionID forKey:@"subscriptionID"];
    [aCoder encodeObject:self.desc forKey:@"desc"];
    [aCoder encodeObject:self.direction forKey:@"direction"];
}

@end
