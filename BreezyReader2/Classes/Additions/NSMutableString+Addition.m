//
//  NSMutableString+Addition.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSMutableString+Addition.h"

@implementation NSMutableString (Addition)

-(void)replaceURLCharacters{
    [self replaceOccurrencesOfString:@"/" 
                          withString:@"%2F"
                             options:NSBackwardsSearch
                               range:NSMakeRange(0, [self length])];
	[self replaceOccurrencesOfString:@":" 
                          withString:@"%3A"
                             options:NSBackwardsSearch
                               range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"?" 
                          withString:@"%3F"
                             options:NSBackwardsSearch
                               range:NSMakeRange(0, [self length])];
}

@end
