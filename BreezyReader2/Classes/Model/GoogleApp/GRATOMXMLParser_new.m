//
//  GRATOMXMLParser_new.m
//  SmallReader
//
//  Created by Jin Jin on 10-10-20.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import "GRATOMXMLParser_new.h"
#import "GRATOMXMLParser_new+private.h"

#define FEED_ELEMENT		"feed"
#define GENERATOR_ELEMENT	"generator"
#define ID_ELEMENT			"id"
#define TITLE_ELEMENT		"title"
#define SUBTITLE_ELEMENT	"subtitle"
//#define CONTINUATION_ELEMENT "gr:continuation"
#define CONTINUATION_ELEMENT "continuation"
//#define LINKINGUSER_ELEMENT "gr:linkinguser"
#define LINKINGUSER_ELEMENT "linkinguser"
#define LINK_ELEMENT		"link"
#define AUTHOR_ELEMENT		"author"
#define NAME_ELEMENT		"name"
#define UPDATED_ELEMENT		"updated"
#define ENTRY_ELEMENT		"entry"

#define CATEGORY_ELEMENT	"category"
#define PUBLISHED_ELEMENT	"published"
#define SUMMARY_ELEMENT		"summary"
#define CONTENT_ELEMENT		"content"
#define SOURCE_ELEMENT		"source"


@implementation GRATOMXMLParser_new

@synthesize XMLSource = _XMLSource;
@synthesize currentParsedCharacterData = _currentParsedCharacterData;
@synthesize parsedFeed = _parsedFeed;
@synthesize currentEntry = _currentEntry;
@synthesize dateFormatter = _dateFormatter;

#pragma mark -
#pragma mark Class life cycle
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
//	DebugLog(@"xml source is %@", [[NSString alloc] initWithData:self.XMLSource encoding:NSUTF8StringEncoding]);
	DebugLog(@"time start");
	_parserContext = xmlCreatePushParserCtxt(&_saxHandlerStruct, self, NULL, 0, NULL);
	xmlParseChunk(_parserContext, (const char*)[self.XMLSource bytes], [self.XMLSource length], 0);
	xmlParseChunk(_parserContext, NULL, 0, 1);
	if (_parserContext) {
        xmlFreeParserCtxt(_parserContext), _parserContext = NULL;
    }
	GRFeed* temp = self.parsedFeed;
	[[temp retain] autorelease];
	self.currentParsedCharacterData = nil;
	self.parsedFeed = nil;
	self.currentEntry = nil;
	self.XMLSource = nil;
	DebugLog(@"time end");
	return temp;
}

#pragma mark -
#pragma mark libxml parse CALLBACK_API

//found element
- (void)startElementLocalName:(const xmlChar*)localname
					   prefix:(const xmlChar*)prefix
						  URI:(const xmlChar*)URI
				nb_namespaces:(int)nb_namespaces
				   namespaces:(const xmlChar**)namespaces
				nb_attributes:(int)nb_attributes
				 nb_defaulted:(int)nb_defaulted
				   attributes:(const xmlChar**)attributes{
/*	NSMutableDictionary* attributeDict = [NSMutableDictionary dictionaryWithCapacity:0];
	for(int i=0; i<nb_attributes; i++)    {        
		// if( *attributes[4] != '\0' ) // something needed here to null terminate the value        
		NSString* key = [NSString stringWithCString:(const char*)attributes[0]
										   encoding:NSUTF8StringEncoding]; 
		NSString* val = [[NSString alloc] initWithBytes:(const void*)attributes[3] 
												 length:(attributes[4] - attributes[3])
											   encoding:NSUTF8StringEncoding]; // it'll be required // [val release];		DebugLog(@"key is %@", key);
//		DebugLog(@"key is %@", key);
//		DebugLog(@"val is %@", val);
        [attributeDict setValue:val forKey:key];     
		[val release];
		attributes +=5;  
	}
		
	
	if (strncmp((char*)localname, FEED_ELEMENT, sizeof(FEED_ELEMENT)) == 0){
		feedLevel = YES;
		GRFeed* tempFeed = [[GRFeed alloc] init];
		self.parsedFeed = tempFeed;
		[tempFeed release];
	}else if (strncmp((char*)localname, GENERATOR_ELEMENT, sizeof(GENERATOR_ELEMENT)) == 0) {
		self.parsedFeed.generator_URI = [attributeDict objectForKey:@"uri"];
	}else if (strncmp((char*)localname, ID_ELEMENT, sizeof(ID_ELEMENT)) == 0) {
		
	}else if (strncmp((char*)localname, TITLE_ELEMENT, sizeof(TITLE_ELEMENT)) == 0) {
		
	}else if (strncmp((char*)localname, SUBTITLE_ELEMENT, sizeof(SUBTITLE_ELEMENT)) == 0) {
		
	}else if (strncmp((char*)localname, CONTINUATION_ELEMENT, sizeof(CONTINUATION_ELEMENT)) == 0) {
		
	}else if (strncmp((char*)localname, LINK_ELEMENT, sizeof(LINK_ELEMENT)) == 0) {
		
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
		
	}else if (strncmp((char*)localname, AUTHOR_ELEMENT, sizeof(AUTHOR_ELEMENT)) == 0) {
		
//		if ([(NSString*)[attributeDict objectForKey:@"gr:unknown-author"] isEqualToString:@"true"]){
//			;
//		}
		if ([(NSString*)[attributeDict objectForKey:@"unknown-author"] isEqualToString:@"true"]){
			;
		}		
	}else if (strncmp((char*)localname, NAME_ELEMENT, sizeof(NAME_ELEMENT)) == 0) {
		
	}else if (strncmp((char*)localname, ENTRY_ELEMENT, sizeof(ENTRY_ELEMENT)) == 0) {
		entryLevel = YES;
		GRItem* tempItem = [[GRItem alloc] init];
		self.currentEntry = tempItem;
		[tempItem release];
	}else if (strncmp((char*)localname, CATEGORY_ELEMENT, sizeof(CATEGORY_ELEMENT)) == 0) {
		NSString* term = (NSString*)[attributeDict objectForKey:@"term"];
		NSString* label = (NSString*)[attributeDict objectForKey:@"label"];
		if (!label){
			label = term;
		}
		[self.currentEntry addCategoryWithLabel:label andTerm:term];
		
	}else if (strncmp((char*)localname, PUBLISHED_ELEMENT, sizeof(PUBLISHED_ELEMENT)) == 0) {
		
	}else if (strncmp((char*)localname, UPDATED_ELEMENT, sizeof(UPDATED_ELEMENT)) == 0) {
		
	}else if (strncmp((char*)localname, SUMMARY_ELEMENT, sizeof(SUMMARY_ELEMENT)) == 0) {
		
	}else if (strncmp((char*)localname, CONTENT_ELEMENT, sizeof(CONTENT_ELEMENT)) == 0) {
		
	}else if (strncmp((char*)localname, LINKINGUSER_ELEMENT, sizeof(LINKINGUSER_ELEMENT)) == 0) {
		
	}else if (strncmp((char*)localname, SOURCE_ELEMENT, sizeof(SOURCE_ELEMENT)) == 0) {
		sourceLevel = YES;
//		self.currentEntry.source = (NSString*)[attributeDict objectForKey:@"gr:stream-id"];
		self.currentEntry.origin_streamId = (NSString*)[attributeDict objectForKey:@"stream-id"];
	}
	
	*/
}

//end found element
- (void)endElementLocalName:(const xmlChar*)localname
					 prefix:(const xmlChar*)prefix URI:(const xmlChar*)URI{
//	DebugLog(@"parsed data is %@", self.currentParsedCharacterData);
/*	if (strncmp((char*)localname, FEED_ELEMENT, sizeof(FEED_ELEMENT)) == 0){
		feedLevel = NO;
	}else if (strncmp((char*)localname, GENERATOR_ELEMENT, sizeof(GENERATOR_ELEMENT)) == 0) {
		
		self.parsedFeed.generator = self.currentParsedCharacterData;
		
	}else if (strncmp((char*)localname, ID_ELEMENT, sizeof(ID_ELEMENT)) == 0) {
		
		if (sourceLevel){
			self.currentEntry.source_ID = self.currentParsedCharacterData;
		}else if (entryLevel) {
			self.currentEntry.ID = self.currentParsedCharacterData;
		}else if (feedLevel) {
			self.parsedFeed.ID = self.currentParsedCharacterData;
		}
		
	}else if (strncmp((char*)localname, TITLE_ELEMENT, sizeof(TITLE_ELEMENT)) == 0) {
		
		if (sourceLevel){
			self.currentEntry.source_title = self.currentParsedCharacterData;
		}else if (entryLevel) {
			self.currentEntry.title = self.currentParsedCharacterData;
		}else if (feedLevel) {
			self.parsedFeed.title = self.currentParsedCharacterData;
		}
		
	}else if (strncmp((char*)localname, SUBTITLE_ELEMENT, sizeof(SUBTITLE_ELEMENT)) == 0) {
		
		self.parsedFeed.subTitle = self.currentParsedCharacterData;
		
	}else if (strncmp((char*)localname, CONTINUATION_ELEMENT, sizeof(CONTINUATION_ELEMENT)) == 0) {
		
		self.parsedFeed.gr_continuation = self.currentParsedCharacterData;
		
	}else if (strncmp((char*)localname, LINK_ELEMENT, sizeof(LINK_ELEMENT)) == 0) {
		
	}else if (strncmp((char*)localname, AUTHOR_ELEMENT, sizeof(AUTHOR_ELEMENT)) == 0) {
		
	}else if (strncmp((char*)localname, NAME_ELEMENT, sizeof(NAME_ELEMENT)) == 0) {
		if (entryLevel){
			self.currentEntry.author = self.currentParsedCharacterData;
		}else if (feedLevel) {
			self.parsedFeed.author = self.currentParsedCharacterData;
		}
	}else if (strncmp((char*)localname, ENTRY_ELEMENT, sizeof(ENTRY_ELEMENT)) == 0) {
		entryLevel = NO;
		self.currentEntry = [GRItem mergeItemToPool:self.currentEntry];
		[self.parsedFeed addItem:self.currentEntry];
		self.currentEntry = nil;
		
	}else if (strncmp((char*)localname, CATEGORY_ELEMENT, sizeof(CATEGORY_ELEMENT)) == 0) {
		
	}else if (strncmp((char*)localname, PUBLISHED_ELEMENT, sizeof(PUBLISHED_ELEMENT)) == 0) {
		
		if (entryLevel){
			self.currentEntry.published = [self.dateFormatter dateFromString:self.currentParsedCharacterData];
		}else if(feedLevel){
			self.parsedFeed.published = [self.dateFormatter dateFromString:self.currentParsedCharacterData];
		}
		
	}else if (strncmp((char*)localname, UPDATED_ELEMENT, sizeof(UPDATED_ELEMENT)) == 0) {
		
		if (entryLevel){
			self.currentEntry.updated = [self.dateFormatter dateFromString:self.currentParsedCharacterData];
		}else if(feedLevel){
			self.parsedFeed.updated = [self.dateFormatter dateFromString:self.currentParsedCharacterData];
		}
		
	}else if (strncmp((char*)localname, SUMMARY_ELEMENT, sizeof(SUMMARY_ELEMENT)) == 0) {
		
		
		self.currentEntry.summary = self.currentParsedCharacterData;
		
		
	}else if (strncmp((char*)localname, CONTENT_ELEMENT, sizeof(CONTENT_ELEMENT)) == 0) {
		
		
		self.currentEntry.content = self.currentParsedCharacterData;
		
		
	}else if (strncmp((char*)localname, LINKINGUSER_ELEMENT, sizeof(LINKINGUSER_ELEMENT)) == 0) {
		
		[self.currentEntry.gr_linkingUsers addObject:self.currentParsedCharacterData];
		
	}else if (strncmp((char*)localname, SOURCE_ELEMENT, sizeof(SOURCE_ELEMENT)) == 0) {
		sourceLevel = NO;
	}
	self.currentParsedCharacterData = nil;
	
	*/
}

//found characters
- (void)charactersFound:(const xmlChar*)ch
					len:(int)len{
	if (!self.currentParsedCharacterData){
		self.currentParsedCharacterData = [NSMutableString stringWithCapacity:0];
	}
	NSString* string = [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
	[self.currentParsedCharacterData appendString:string];
	[string release];
	
}

//found attributes
- (void)attributeHandler:(const xmlChar*)elem
				fullname:(const xmlChar*)fullname 
					type:(int)type def:(int)def 
			defaultValue:(const xmlChar*)defaultValue
					tree:(xmlEnumerationPtr)tree{
	
	printf("\n");
	printf("elem is %s\n", elem);
	
	printf("fullname is %s\n", fullname);
	
	printf("value is %s\n", tree->name);
	
}

@end
