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

@property (nonatomic, strong) NSString*	generator;
@property (nonatomic, strong) NSString*	generator_URI;
@property (nonatomic, strong) NSString*	ID;
@property (nonatomic, strong) NSString*	selfLink;
@property (nonatomic, strong) NSString*	alternateLink;
@property (nonatomic, strong) NSString*	title;
@property (nonatomic, strong) NSString*	subTitle;
@property (nonatomic, strong) NSString*	gr_continuation;
@property (nonatomic, strong) NSString*	author;
@property (nonatomic, strong) NSDate*	updated;
@property (nonatomic, strong) NSDate*	published;
@property (nonatomic, strong) NSDate*	refreshed;
@property (nonatomic, strong) NSMutableArray* items;
@property (nonatomic, strong) NSMutableSet* itemIDs;
@property (nonatomic, strong) NSData*	sourceXML;
@property (nonatomic, strong) NSString* subscriptionID;

@property (nonatomic, strong) NSMutableArray* sortArray;

@property (nonatomic, readonly) NSArray* imageURLs; 

@property (nonatomic, strong) NSString* desc;
@property (nonatomic, strong) NSString* direction;

-(void)sortItems;
-(void)addItem:(GRItem*)item;
-(NSString*)presentationString;
-(GRFeed*)mergeWithFeed:(GRFeed*)feed continued:(BOOL)continued;
-(NSInteger)itemCount;
-(GRItem*)getItemAtIndex:(NSUInteger)index;

+(id)objWithJSON:(NSDictionary*)json;

@end
