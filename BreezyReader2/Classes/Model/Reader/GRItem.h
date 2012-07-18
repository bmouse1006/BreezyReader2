//
//  Entry.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-7.
//  retainright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRBaseProtocol.h"
#import "GoogleAppConstants.h"

@interface GRItem : NSObject<GRBaseProtocol> 

@property (nonatomic, strong) NSString*	ID;
@property (nonatomic, strong) NSString*	title;
@property (nonatomic, strong) NSDate*	published;
@property (nonatomic, strong) NSDate*	updated;
@property (nonatomic, strong) NSString*	selfLink;
@property (nonatomic, strong) NSString*	alternateLink;
@property (nonatomic, strong) NSString*	summary;
@property (nonatomic, strong) NSString*	content;
@property (nonatomic, strong) NSString*	author;

@property (nonatomic, strong) NSMutableSet* gr_linkingUsers;
@property (nonatomic, strong) NSMutableSet* categories;

@property (nonatomic, strong) NSString*	origin_htmlUrl;
@property (nonatomic, strong) NSString*	origin_streamId;
@property (nonatomic, strong) NSString*	origin_title;

@property (nonatomic, strong) NSString* shortPresentDateTime;

@property (nonatomic, strong) NSArray* contentImageURLs;
@property (nonatomic, strong) NSArray* summaryImageURLs;
@property (nonatomic, strong) NSDictionary* imageURLFileMap;

@property (nonatomic, assign) BOOL isReadStateLocked;

@property (nonatomic, readonly, assign) BOOL readed;
@property (nonatomic, readonly, assign) BOOL starred;
@property (nonatomic, readonly, assign) BOOL keptUnread;

@property (nonatomic, readonly, getter=getPlainSummary) NSString* plainSummary;
@property (nonatomic, readonly, getter=getPlainContent) NSString* plainContent;

-(NSString*)presentationString;
-(NSString*)getShortUpdatedDateTime;

-(GRItem*)mergeWithItem:(GRItem*)item;

-(BOOL)isReaded;
-(BOOL)isStarred;

-(void)markAsRead;
-(void)keepUnread;
-(void)removeKeepUnread;
-(void)markAsStarred;
-(void)markAsUnstarred;

-(void)removeCategory:(NSString*)category;
-(void)addCategory:(NSString*)category;

+(GRItem*)mergeItemToPool:(GRItem*)item;
+(void)didReceiveMemoryWarning;

-(BOOL)containsState:(NSString*)state;

//get a list of image URL
-(NSArray*)imageURLList;

-(void)downloadedImageFilePath:(NSDictionary*)URLFilePathMap;

-(void)parseImagesFromSummaryAndContent;

-(NSString*)filePathForImageURLString:(NSString*)urlString;
-(NSString*)encryptedImageFileName:(NSString*)imageURL;

+(id)objWithJSON:(NSDictionary*)json;

@end
