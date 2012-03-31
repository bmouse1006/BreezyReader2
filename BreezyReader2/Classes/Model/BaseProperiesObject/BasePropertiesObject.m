//
//  BasePropertiesObject.m
//  BreezyReader2
//
//  Created by 金 津 on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BasePropertiesObject.h"

@implementation BasePropertiesObject

@synthesize properties = _properties;

-(void)dealloc{
    self.properties = nil;
    [super dealloc];
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    DebugLog(@"property %@ doesn't exist in %@", key, NSStringFromClass([self class]));
}

-(void)setProperties:(NSDictionary *)properties{
    if (_properties != properties){
        [_properties release];
        _properties = properties;
        [_properties retain];
        NSArray* keys = [_properties allKeys];
        for (id key in keys){
            [self setValue:[_properties valueForKey:key] forKey:key];
        }
    }
}

+(id)objWithProperties:(NSDictionary*)properties{
    BasePropertiesObject* obj = [[self alloc] init];
    obj.properties = properties;
    return [obj autorelease];
}

@end
