//
//  Entry.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-7.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GRItem.h"
#import "RegexKitLite.h"
#import "NSString+MD5.h"
#import "NSString+Addtion.h"
#import "ImageFilter.h"

#define PATTERN @"<.*?>"

@interface GRItem ()

-(NSArray*)filterredImagesFromArray:(NSArray*)array;
-(NSArray*)getAllImageURL:(NSString*)article;

-(void)addCategory:(NSString*)category;
-(void)removeCategory:(NSString*)category;

@end

@implementation GRItem

@synthesize ID = _ID;
@synthesize	title = _title;
@synthesize	published = _published;
@synthesize	updated = _updated;
@synthesize	selfLink = _selfLink;
@synthesize	alternateLink = _alternateLink;
@synthesize	summary = _summary;
@synthesize content = _content;
@synthesize	author = _author;
@synthesize gr_linkingUsers = _gr_linkingUsers;
@synthesize categories = _categories;
@synthesize shortPresentDateTime = _shortPresentDateTime;
@synthesize origin_title = _origin_title, origin_htmlUrl = _origin_htmlUrl, origin_streamId = _origin_streamId;

@synthesize readed = _readed, starred = _starred, keptUnread = _keptUnread;
@synthesize contentImageURLs = _contentImageURLs;
@synthesize summaryImageURLs = _summaryImageURLs;
@synthesize imageURLFileMap = _imageURLFileMap;

@synthesize plainSummary = _plainSummary;
@synthesize plainContent = _plainContent;

@synthesize isReadStateLocked = _isReadStateLocked;

+(id)objWithJSON:(NSDictionary*)json{
    GRItem* item = [[[self alloc] init] autorelease];
    
    item.ID = [json objectForKey:@"id"];
    item.title = [json objectForKey:@"title"];
    item.updated = [NSDate dateWithTimeIntervalSince1970:[[json objectForKey:@"updated"] intValue]];
    item.published = [NSDate dateWithTimeIntervalSince1970:[[json objectForKey:@"published"] intValue]];
    NSDictionary* origin = [json objectForKey:@"origin"];
    item.origin_title = [origin objectForKey:@"title"];
    item.origin_streamId = [origin objectForKey:@"streamId"];
    item.origin_htmlUrl = [origin objectForKey:@"htmlUrl"];
    NSArray* categories = [json objectForKey:@"categories"];
    for (NSString* category in categories){
        [item addCategory:category];
    }
    item.content = [[json objectForKey:@"content"] objectForKey:@"content"];
    item.summary = [[json objectForKey:@"summary"] objectForKey:@"content"];
    item.author = [json objectForKey:@"author"];
    item.isReadStateLocked = [[json objectForKey:@"isReadStateLocked"] boolValue];
    
    if ([[json objectForKey:@"alternate"] count] > 0){
        item.alternateLink = [[[json objectForKey:@"alternate"] objectAtIndex:0] objectForKey:@"href"];
    }
    
    return item;
}

-(NSString*)getPlainSummary{
	if (_plainSummary){
		return _plainSummary;
	}
	
	_plainSummary = [[self.summary stringByReplacingHTMLTagAndTrim] retain];
	
	return _plainSummary;
}

-(NSString*)getPlainContent{
	if (_plainContent){
		return _plainContent;
	}
	_plainContent = [[self.content stringByReplacingHTMLTagAndTrim] retain];
	return _plainContent;
}

-(void)parseImagesFromSummaryAndContent{
	if (!self.summaryImageURLs){
        self.summaryImageURLs = [self filterredImagesFromArray:[self getAllImageURL:self.summary]];
	}
	
	if (!self.contentImageURLs){
		self.contentImageURLs = [self filterredImagesFromArray:[self getAllImageURL:self.content]];
	}
}

-(NSArray*)imageURLList{
	[self parseImagesFromSummaryAndContent];
	NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
	[array addObjectsFromArray:self.summaryImageURLs];
    [array addObjectsFromArray:self.contentImageURLs];
	
	return array;
}

-(void)downloadedImageFilePath:(NSDictionary*)URLFilePathMap{
	self.imageURLFileMap = URLFilePathMap;
}

-(void)markAsRead{
	NSString* readTag = [ATOM_PREFIX_STATE_GOOGLE stringByAppendingString:ATOM_STATE_READ];
    [self addCategory:readTag];
}

-(void)keepUnread{
    NSString* readTag = [ATOM_PREFIX_STATE_GOOGLE stringByAppendingString:ATOM_STATE_UNREAD];
    [self addCategory:readTag];
}

-(void)removeKeepUnread{
    NSString* readTag = [ATOM_PREFIX_STATE_GOOGLE stringByAppendingString:ATOM_STATE_UNREAD];
    [self removeCategory:readTag];
}

-(void)markAsStarred{
    NSString* readTag = [ATOM_PREFIX_STATE_GOOGLE stringByAppendingString:ATOM_STATE_STARRED];
    [self addCategory:readTag];
}

-(void)markAsUnstarred{
    NSString* readTag = [ATOM_PREFIX_STATE_GOOGLE stringByAppendingString:ATOM_STATE_STARRED];
    [self removeCategory:readTag];
}

-(BOOL)containsState:(NSString*)state{
	
	NSString* key = [ATOM_PREFIX_STATE_GOOGLE stringByAppendingString:state];
	
	return [self.categories containsObject:key];
}

-(NSString*)getShortUpdatedDateTime{
	
	if (!self.shortPresentDateTime){
		NSDate* today = [NSDate date];
		NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
		
		[formatter setTimeZone:[NSTimeZone localTimeZone]];
		[formatter setDateFormat:@"yyyy.MM.dd"];
		
		today = [formatter dateFromString:[formatter stringFromDate:today]];
		NSDate* modifiedUpdatedDate = [formatter dateFromString:[formatter stringFromDate:self.updated]];
		
		if ([today isEqualToDate:modifiedUpdatedDate]){
			[formatter setDateFormat:@"HH:mm"];
		}else {
			[formatter setDateFormat:@"MM/dd"];
		}
		
		[formatter setTimeZone:[NSTimeZone localTimeZone]];
		self.shortPresentDateTime = [formatter stringFromDate:self.updated];
		[formatter release];
	}
	return self.shortPresentDateTime;
}

-(NSString*)presentationString{
	return self.title;
}

-(BOOL)isReaded{

	return (_keptUnread)?NO:_readed;
}

-(BOOL)isStarred{
	return _starred;
}

-(GRItem*)mergeWithItem:(GRItem*)item{
	[item retain];
	if ([self.ID isEqualToString:item.ID]){
		//only below three fields will be updated
		//don't need to consider other situation
		self.updated = item.updated;				
		self.gr_linkingUsers = item.gr_linkingUsers;
		self.categories = item.categories;
	}
	[item release];
	return self;
}

-(NSString*)filePathForImageURLString:(NSString*)urlString{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	if (!documentsDirectory) {
		DebugLog(@"Documents directory not found!");
		return @"";
	}
	
	NSString* filename = [@"/" stringByAppendingString:[self encryptedImageFileName:urlString]];
	NSString* filePath = [documentsDirectory stringByAppendingString:filename];
	return filePath;
}

-(NSString*)encryptedImageFileName:(NSString*)imageURL{
	return [[[self.ID MD5] stringByAppendingString:[imageURL MD5]] stringByAppendingString:@".jpg"];
}

-(void)dealloc{
	
    self.ID = nil;
    self.title = nil;
    self.selfLink = nil;
    self.alternateLink = nil;
    self.summary = nil;
    self.content = nil;
    self.author = nil;
    self.origin_streamId = nil;
    self.origin_htmlUrl = nil;
    self.origin_title = nil;
    
    self.updated = nil;
    self.published = nil;
    self.gr_linkingUsers = nil;
    self.categories = nil;
    
    self.contentImageURLs = nil;
    self.summaryImageURLs = nil;
    self.imageURLFileMap = nil;
    self.shortPresentDateTime = nil;

	[_plainContent release];
	[_plainSummary release];
	
	[super dealloc];
}

-(id)init{
	if (self = [super init]){
		self.gr_linkingUsers = [NSMutableSet set];
		self.categories = [NSMutableSet set];
		self.shortPresentDateTime = nil;
		self.contentImageURLs = nil;
		self.summaryImageURLs = nil;
		self.imageURLFileMap = nil;
		
		_readed = NO;
		_keptUnread = NO;
		_starred = NO;
		
		_plainContent = nil;
		_plainSummary = nil;
	}
	return self;
} 

-(NSUInteger)hash{
	return [self.ID hash];
}

-(NSComparisonResult)compare:(id)object{
	return [self.updated compare:[(GRItem*)object updated]];
}

static NSMutableDictionary* itemPool = nil;

+(GRItem*)mergeItemToPool:(GRItem*)item{
	[item retain];
	if (!itemPool){
		itemPool = [[NSMutableDictionary alloc] initWithCapacity:0];
	}
	
	GRItem* returnItem = [itemPool objectForKey:item.ID];
	if (returnItem){
		[returnItem mergeWithItem:item];
	}else {
		[itemPool setObject:item forKey:item.ID];
		returnItem = item;
	}
	[item release];
	return returnItem;

}

+(void)didReceiveMemoryWarning{
	[itemPool removeAllObjects];
}

-(NSArray*)getAllImageURL:(NSString*)article{
	//regular expression to get images
	NSString* imagePattern = @"(?i)<\\s*img\\s*.*?\\s*src\\s*=\\s*[\"']?\\s*([^\\s'\"]*)\\s*[\"']?\\s*.*?>";
	NSArray* allParsedImageURL = [article arrayOfCaptureComponentsMatchedByRegex:imagePattern];
    NSMutableArray* urls = [NSMutableArray array];
	for (id object in allParsedImageURL){
	  	[urls addObject:[object objectAtIndex:1]];
	}
	return urls;
}

-(NSArray*)filterredImagesFromArray:(NSArray*)array{
    NSMutableArray* images = [NSMutableArray array];
    for (NSString* url in array){
        if ([ImageFilter shouldFiltImage:url] == NO){
            [images addObject:url];
        }
    }
    return images;
}

-(void)addCategory:(NSString*)category{
    if (category == nil){
        return;
    }
    NSMutableString* mcate = [NSMutableString stringWithString:category];
	NSArray* tokens = [category componentsSeparatedByString:@"/"];
	NSString* type = nil;
    NSString* label = nil;
	if ([tokens count] >= 3){
		type = [tokens objectAtIndex:2];
        label = [tokens lastObject];
		[mcate replaceOccurrencesOfString:[tokens objectAtIndex:1] 
								 withString:@"-" 
									options:NSForcedOrderingSearch	
									  range:NSMakeRange(0, [mcate length])];
	}
	
	if ( [type isEqualToString:@"state"]){//dont' deal with type of 'label'
		if ([label isEqualToString:ATOM_STATE_UNREAD]){
			_keptUnread = YES;
		}else if ([label isEqualToString:ATOM_STATE_READ]) {
			_readed = YES;
		}else if ([label isEqualToString:ATOM_STATE_STARRED]){
			_starred = YES;
		}
		
	}
	
    [self.categories addObject:category];
}

-(void)removeCategory:(NSString *)category{
    if (category == nil){
        return;
    }
    NSArray* tokens = [category componentsSeparatedByString:@"/"];
    NSString* type = nil;
    NSString* label = nil;
    if ([tokens count] >= 3){
        type = [tokens objectAtIndex:2];
        label = [tokens lastObject];
    }
    
    if ( [type isEqualToString:@"state"]){//dont' deal with type of 'label'
        if ([label isEqualToString:ATOM_STATE_UNREAD]){
            _keptUnread = NO;
        }else if ([label isEqualToString:ATOM_STATE_READ]) {
            _readed = NO;
        }else if ([label isEqualToString:ATOM_STATE_STARRED]){
            _starred = NO;
        }
        
    }
    
    [self.categories removeObject:category];
}

@end

