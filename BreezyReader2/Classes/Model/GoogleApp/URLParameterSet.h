//
//  URLParameterSet.h
//  BreezyReader
//
//  Created by Jin Jin on 10-6-7.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ParameterPair : NSObject

@property (nonatomic, copy) NSString* key;
@property (nonatomic, copy) NSString* value;

+(id)pairWithKey:(NSString*)key andValue:(id)value;

@end

@interface URLParameterSet : NSObject 

-(NSString*)parameterString;

-(NSArray*)allPairs;

-(void)setParameterForKey:(NSString*)key withValue:(NSObject*)value;

@end
