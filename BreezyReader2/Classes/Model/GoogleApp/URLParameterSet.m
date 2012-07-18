//
//  URLParameterSet.m
//  BreezyReader
//
//  Created by Jin Jin on 10-6-7.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "URLParameterSet.h"
#import "NSString+Addition.h"
#import "GoogleAppConstants.h"

@implementation ParameterPair

@synthesize key = _key, value = _value;


+(id)pairWithKey:(NSString *)key andValue:(id)value{
    ParameterPair* pair = [[ParameterPair alloc] init];
    
    pair.key = key;
    if ([value isKindOfClass:[NSString class]]){
        pair.value = value;
    }
    
    if ([value isKindOfClass:[NSDate class]]){
        NSTimeInterval secondes = [(NSDate*)value timeIntervalSince1970];
        pair.value = [NSString stringWithFormat:@"%d", secondes];
    }
    
    if ([value isKindOfClass:[NSNumber class]]){
        pair.value = [(NSNumber*)value stringValue];
    }		
    
    return pair;
}

@end

@interface URLParameterSet()

@property (nonatomic, strong) NSMutableArray* parameters;

@end

@implementation URLParameterSet

@synthesize parameters = _parameters;

-(NSString*)parameterString{

	NSMutableString* compliedString = [[NSMutableString alloc] init];
	
	for (ParameterPair* pair in self.parameters){
		
        id key = pair.key;
        id value = pair.value;
		
		[compliedString appendString:key];
		[compliedString appendString:@"="];
		
		if ([value isKindOfClass:[NSString class]]){
			[compliedString appendString:(NSString*)value];
		}
		
		if ([value isKindOfClass:[NSDate class]]){
			NSTimeInterval secondes = [(NSDate*)value timeIntervalSince1970];
			[compliedString appendFormat:@"%d", secondes];
		}
		
		if ([value isKindOfClass:[NSNumber class]]){
			[compliedString appendString:[(NSNumber*)value stringValue]];
		}								  
			[compliedString appendString:@"&"];								  
	}
	
//	NSMutableString* encodedString = [NSMutableString stringWithCapacity:0];
//	[encodedString setString:[compliedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//	
//    [encodedString replaceURLCharacters];
    
    NSString* encodedString = [compliedString stringByAddingPercentEscapesAndReplacingHTTPCharacter];
    
	DebugLog(@"encoded parameter string is %@", encodedString);
	
	return [encodedString stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
}

-(void)setParameterForKey:(NSString*)key withValue:(NSObject*)value{
    
    if (key.length > 0 && value){
        ParameterPair* pair = [ParameterPair pairWithKey:key andValue:value];
        [self.parameters addObject:pair];
    }
}

-(NSArray*)allPairs{
    return [NSArray arrayWithArray:self.parameters];
}

-(id)init{
	if (self = [super init]){
        self.parameters = [NSMutableArray array];
		//default parameter for all request
		[self setParameterForKey:@"client" withValue:CLIENT_IDENTIFIER];
	}
	return self;
}

				
										  

@end
