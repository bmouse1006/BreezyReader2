//
//  GRATOMXMLParser_new.h
//  SmallReader
//
//  Created by Jin Jin on 10-10-20.
//  Copyright 2010 Jin Jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>
#import "GRFeed.h"
#import "GRItem.h"		

@interface GRATOMXMLParser_new : NSObject {

	BOOL accumulatingParsedCharacterData;
	BOOL feedLevel;
	BOOL entryLevel;
	BOOL sourceLevel;

	xmlParserCtxtPtr _parserContext;
	
}

@property (nonatomic, retain) NSData* XMLSource;
@property (nonatomic, retain) GRItem* currentEntry;
@property (nonatomic, retain) GRFeed*	parsedFeed;
@property (nonatomic, retain) NSMutableString* currentParsedCharacterData;

@property (nonatomic, retain) NSDateFormatter* dateFormatter;

-(id)initWithXMLData:(NSData*)data;

-(id)parse;

@end
