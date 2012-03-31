//
//  GoogleMessageParsers.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRATOMXMLParser.h"
#import "GRATOMXMLParser_new.h"
#import "JSON.h"
#import "GRFeed.h"

@interface GoogleMessageParsers : NSObject {

}

+(NSDictionary*)JSONParser:(NSData*)source;//parser for JSON message
+(NSString*)EDITParser:(NSData*)source;//Parser for Edit return message
+(id)ATOMParser:(NSData*)source;//Parser for ATOM return message (ATOM XML)
+(NSDictionary*)SEARCHParser:(NSData*)source;//parser for feed search result

+(void)printJSONObject:(NSDictionary*)JSONObject level:(int)l;//recursive print JSON info

@end
