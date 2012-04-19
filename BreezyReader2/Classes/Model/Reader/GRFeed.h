//
//  GRFeed.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-7.
//  retainright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRBaseProtocol.h"
#import "GRItem.h"

@interface GRFeed : NSObject<GRBaseProtocol, NSCoding>

@property (nonatomic, retain) NSString*	generator;
@property (nonatomic, retain) NSString*	generator_URI;
@property (nonatomic, retain) NSString*	ID;
@property (nonatomic, retain) NSString*	selfLink;
@property (nonatomic, retain) NSString*	alternateLink;
@property (nonatomic, retain) NSString*	title;
@property (nonatomic, retain) NSString*	subTitle;
@property (nonatomic, retain) NSString*	gr_continuation;
@property (nonatomic, retain) NSString*	author;
@property (nonatomic, retain) NSDate*	updated;
@property (nonatomic, retain) NSDate*	published;
@property (nonatomic, retain) NSDate*	refreshed;
@property (nonatomic, retain) NSMutableArray* items;
@property (nonatomic, retain) NSMutableSet* itemIDs;
@property (nonatomic, retain) NSData*	sourceXML;
@property (nonatomic, retain) NSString* subscriptionID;

@property (nonatomic, retain) NSMutableArray* sortArray;

@property (nonatomic, readonly) NSArray* imageURLs; 

@property (nonatomic, retain) NSString* desc;
@property (nonatomic, retain) NSString* direction;

-(void)sortItems;
-(void)addItem:(GRItem*)item;
-(NSString*)presentationString;
-(GRFeed*)mergeWithFeed:(GRFeed*)feed continued:(BOOL)continued;
-(NSInteger)itemCount;
-(GRItem*)getItemAtIndex:(NSUInteger)index;

+(id)objWithJSON:(NSDictionary*)json;

@end
