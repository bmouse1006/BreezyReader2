
//
//  NSString+Addition.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+Addition.h"
#import "RegexKitLite.h"
#import "NSString+MD5.h"

#define PATTERN @"<.*?>"

@implementation NSString (addition)

-(NSString*)stringByReplacingHTMLTagAndTrim{
    NSString* str = [self stringByReplacingOccurrencesOfRegex:PATTERN 
                                                     withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
}

-(NSString*)stringByAddingPercentEscapesAndReplacingHTTPCharacter{
    NSString* string = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableString* ms = [[string mutableCopy] autorelease];
    [ms replaceOccurrencesOfString:@"/" 
                          withString:@"%2F"
                             options:NSBackwardsSearch
                               range:NSMakeRange(0, [ms length])];
	[ms replaceOccurrencesOfString:@":" 
                          withString:@"%3A"
                             options:NSBackwardsSearch
                               range:NSMakeRange(0, [ms length])];
    [ms replaceOccurrencesOfString:@"?" 
                          withString:@"%3F"
                             options:NSBackwardsSearch
                               range:NSMakeRange(0, [ms length])];
    
    return ms;
}

-(UIColor*)colorForString{
    NSUInteger hash = [self hash];
    NSUInteger mask = 0xff;
    CGFloat red = hash & mask;
    CGFloat green = (hash >> 8) & mask;
    CGFloat blue = (hash >> 8) & mask;
    
    return [UIColor colorWithRed:red/255 green:green/255 blue:blue/255 alpha:1];
}

@end
