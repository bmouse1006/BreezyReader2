//
//  BasePropertiesObject.h
//  BreezyReader2
//
//  Created by 金 津 on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BasePropertiesObject : NSObject

@property (nonatomic, setter = setProperties:) NSDictionary* properties;

+(id)objWithProperties:(NSDictionary*)properties;

@end
