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

@property (nonatomic, retain) NSString*	ID;
@property (nonatomic, retain) NSString*	title;
@property (nonatomic, retain) NSDate*	published;
@property (nonatomic, retain) NSDate*	updated;
@property (nonatomic, retain) NSString*	selfLink;
@property (nonatomic, retain) NSString*	alternateLink;
@property (nonatomic, retain) NSString*	summary;
@property (nonatomic, retain) NSString*	content;
@property (nonatomic, retain) NSString*	author;

@property (nonatomic, retain) NSMutableSet* gr_linkingUsers;
@property (nonatomic, retain) NSMutableSet* categories;

@property (nonatomic, retain) NSString*	origin_htmlUrl;
@property (nonatomic, retain) NSString*	origin_streamId;
@property (nonatomic, retain) NSString*	origin_title;

@property (nonatomic, retain) NSString* shortPresentDateTime;

@property (nonatomic, retain) NSArray* contentImageURLs;
@property (nonatomic, retain) NSArray* summaryImageURLs;
@property (nonatomic, retain) NSDictionary* imageURLFileMap;

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
