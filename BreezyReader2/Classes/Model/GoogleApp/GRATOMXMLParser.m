//
//  GRATOMXMLParser.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GRATOMXMLParser.h"


@implementation GRATOMXMLParser

@synthesize XMLSource = _XMLSource;
@synthesize currentParsedCharacterData = _currentParsedCharacterData;
@synthesize parsedFeed = _parsedFeed;
@synthesize currentEntry = _currentEntry;
@synthesize dateFormatter = _dateFormatter;

static NSString* const FEED_ELEMENT = @"feed";
static NSString* const GENERATOR_ELEMENT = @"generator";
static NSString* const ID_ELEMENT = @"id";
static NSString* const TITLE_ELEMENT = @"title";
static NSString* const SUBTITLE_ELEMENT = @"subtitle";
static NSString* const CONTINUATION_ELEMENT = @"gr:continuation";
static NSString* const LINKINGUSER_ELEMENT = @"gr:linkinguser";
static NSString* const LINK_ELEMENT = @"link";
static NSString* const AUTHOR_ELEMENT = @"author";
static NSString* const NAME_ELEMENT = @"name";
static NSString* const UPDATED_ELEMENT = @"updated";
static NSString* const ENTRY_ELEMENT = @"entry";

static NSString* const CATEGORY_ELEMENT = @"category";
static NSString* const PUBLISHED_ELEMENT = @"published";
static NSString* const SUMMARY_ELEMENT = @"summary";
static NSString* const CONTENT_ELEMENT = @"content";
static NSString* const SOURCE_ELEMENT = @"source";

-(id)initWithXMLData:(NSData*)data{

	if (self = [super init]){
		self.XMLSource = data;
		feedLevel = NO;
		entryLevel = NO;
		sourceLevel = NO;
		NSDateFormatter* tempFormatter = [[NSDateFormatter alloc] init];
		[tempFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
		[tempFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
		self.dateFormatter = tempFormatter;
		[tempFormatter release];
	}
	
	return self;
}

-(void)dealloc{
	
    self.XMLSource = nil;
    self.currentParsedCharacterData = nil;
    self.currentEntry = nil;
    self.parsedFeed = nil;
    self.dateFormatter = nil;
	[super dealloc];
}

-(id)parse{	
	DebugLog(@"time start");
	NSString* source = [[NSString alloc] initWithData:self.XMLSource encoding:NSUTF8StringEncoding];
//	DebugLog(@"%@", source);
	[source release];
	
	NSXMLParser* myParser = [[NSXMLParser alloc] initWithData:self.XMLSource];
	[myParser setDelegate:self];
	[myParser parse];
	[myParser release];	
//	[self.parsedFeed sortItems];
	self.currentParsedCharacterData = nil;
	GRFeed* temp = self.parsedFeed;
	[[temp retain] autorelease];
	self.parsedFeed = nil;
	self.currentEntry = nil;
	self.XMLSource = nil;
	DebugLog(@"time end");
	return temp;
}

//delegate methods
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
/*	
	if ([elementName isEqualToString:FEED_ELEMENT]){
		feedLevel = YES;
		GRFeed* tempFeed = [[GRFeed alloc] init];
		self.parsedFeed = tempFeed;
		[tempFeed release];
	}else if ([elementName isEqualToString:GENERATOR_ELEMENT]) {
		self.parsedFeed.generator_URI = [attributeDict objectForKey:@"uri"];
	}else if ([elementName isEqualToString:ID_ELEMENT]) {
		
	}else if ([elementName isEqualToString:TITLE_ELEMENT]) {
		
	}else if ([elementName isEqualToString:SUBTITLE_ELEMENT]) {
		
	}else if ([elementName isEqualToString:CONTINUATION_ELEMENT]) {
		
	}else if ([elementName isEqualToString:LINK_ELEMENT]) {
		
		if (sourceLevel){
			if ([(NSString*)[attributeDict objectForKey:@"rel"] isEqualToString:@"self"]){
				self.currentEntry.source_selfLink = [attributeDict objectForKey:@"href"];
			}else if ([(NSString*)[attributeDict objectForKey:@"rel"] isEqualToString:@"alternate"]) {
				self.currentEntry.source_alternateLink = [attributeDict objectForKey:@"href"];
			}
		}else if (entryLevel) {
			if ([(NSString*)[attributeDict objectForKey:@"rel"] isEqualToString:@"self"]){
				self.currentEntry.selfLink = [attributeDict objectForKey:@"href"];
			}else if ([(NSString*)[attributeDict objectForKey:@"rel"] isEqualToString:@"alternate"]) {
				self.currentEntry.alternateLink = [attributeDict objectForKey:@"href"];
			}
		}else if (feedLevel) {
			if ([(NSString*)[attributeDict objectForKey:@"rel"] isEqualToString:@"self"]){
				self.parsedFeed.selfLink = [attributeDict objectForKey:@"href"];
			}else if ([(NSString*)[attributeDict objectForKey:@"rel"] isEqualToString:@"alternate"]) {
				self.parsedFeed.alternateLink = [attributeDict objectForKey:@"href"];
			}
		}
		
	}else if ([elementName isEqualToString:AUTHOR_ELEMENT]) {
		
		if ([(NSString*)[attributeDict objectForKey:@"gr:unknown-author"] isEqualToString:@"true"]){
			;
		}
		
	}else if ([elementName isEqualToString:NAME_ELEMENT]) {
		
	}else if ([elementName isEqualToString:ENTRY_ELEMENT]) {
		entryLevel = YES;
		GRItem* tempItem = [[GRItem alloc] init];
		self.currentEntry = tempItem;
		[tempItem release];
	}else if ([elementName isEqualToString:CATEGORY_ELEMENT]) {
		NSString* term = (NSString*)[attributeDict objectForKey:@"term"];
		NSString* label = (NSString*)[attributeDict objectForKey:@"label"];
		if (!label){
			label = term;
		}
		[self.currentEntry addCategoryWithLabel:label andTerm:term];
		
	}else if ([elementName isEqualToString:PUBLISHED_ELEMENT]) {
		
	}else if ([elementName isEqualToString:UPDATED_ELEMENT]) {
		
	}else if ([elementName isEqualToString:SUMMARY_ELEMENT]) {
		
	}else if ([elementName isEqualToString:CONTENT_ELEMENT]) {
		
	}else if ([elementName isEqualToString:LINKINGUSER_ELEMENT]) {
		
	}else if ([elementName isEqualToString:SOURCE_ELEMENT]) {
		sourceLevel = YES;
		self.currentEntry.source = (NSString*)[attributeDict objectForKey:@"gr:stream-id"];
	}*/
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
					  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{

/*	if ([elementName isEqualToString:FEED_ELEMENT]){
		feedLevel = NO;
	}else if ([elementName isEqualToString:GENERATOR_ELEMENT]) {
		
		self.parsedFeed.generator = self.currentParsedCharacterData;
		
	}else if ([elementName isEqualToString:ID_ELEMENT]) {
		
		if (sourceLevel){
			self.currentEntry.source_ID = self.currentParsedCharacterData;
		}else if (entryLevel) {
			self.currentEntry.ID = self.currentParsedCharacterData;
		}else if (feedLevel) {
			self.parsedFeed.ID = self.currentParsedCharacterData;
		}
	  
	}else if ([elementName isEqualToString:TITLE_ELEMENT]) {
		
		if (sourceLevel){
			self.currentEntry.source_title = self.currentParsedCharacterData;
		}else if (entryLevel) {
			self.currentEntry.title = self.currentParsedCharacterData;
		}else if (feedLevel) {
			self.parsedFeed.title = self.currentParsedCharacterData;
		}
		
	}else if ([elementName isEqualToString:SUBTITLE_ELEMENT]) {
		
		self.parsedFeed.subTitle = self.currentParsedCharacterData;
		
	}else if ([elementName isEqualToString:CONTINUATION_ELEMENT]) {
	  
		self.parsedFeed.gr_continuation = self.currentParsedCharacterData;
		
	}else if ([elementName isEqualToString:LINK_ELEMENT]) {
	  
	}else if ([elementName isEqualToString:AUTHOR_ELEMENT]) {
	  
	}else if ([elementName isEqualToString:NAME_ELEMENT]) {
		if (entryLevel){
			self.currentEntry.author = self.currentParsedCharacterData;
		}else if (feedLevel) {
			self.parsedFeed.author = self.currentParsedCharacterData;
		}
	}else if ([elementName isEqualToString:ENTRY_ELEMENT]) {
		entryLevel = NO;
		self.currentEntry = [GRItem mergeItemToPool:self.currentEntry];
		[self.parsedFeed addItem:self.currentEntry];
		self.currentEntry = nil;
		
	}else if ([elementName isEqualToString:CATEGORY_ELEMENT]) {
		
	}else if ([elementName isEqualToString:PUBLISHED_ELEMENT]) {
		
		if (entryLevel){
			self.currentEntry.published = [self.dateFormatter dateFromString:self.currentParsedCharacterData];
		}else if(feedLevel){
			self.parsedFeed.published = [self.dateFormatter dateFromString:self.currentParsedCharacterData];
		}
	  
	}else if ([elementName isEqualToString:UPDATED_ELEMENT]) {
		
		if (entryLevel){
			self.currentEntry.updated = [self.dateFormatter dateFromString:self.currentParsedCharacterData];
		}else if(feedLevel){
			self.parsedFeed.updated = [self.dateFormatter dateFromString:self.currentParsedCharacterData];
		}
		
	}else if ([elementName isEqualToString:SUMMARY_ELEMENT]) {

		
		self.currentEntry.summary = self.currentParsedCharacterData;

		
	}else if ([elementName isEqualToString:CONTENT_ELEMENT]) {
		
		
		self.currentEntry.content = self.currentParsedCharacterData;
		
		
	}else if ([elementName isEqualToString:LINKINGUSER_ELEMENT]) {
		
		[self.currentEntry.gr_linkingUsers addObject:self.currentParsedCharacterData];
		
	}else if ([elementName isEqualToString:SOURCE_ELEMENT]) {
		sourceLevel = NO;
	}
	self.currentParsedCharacterData = nil;*/
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (!self.currentParsedCharacterData){
		NSMutableString* mString = [[NSMutableString alloc] initWithString:string];
		self.currentParsedCharacterData = mString;
		[mString release];
	}else {
		[self.currentParsedCharacterData appendString:string];
	}
	
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	self.parsedFeed = nil;
}
@end
