
//
//  NSString+Addtion.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+Addtion.h"
#import "RegexKitLite.h"

#define PATTERN @"<.*?>"

@implementation NSString (Addtion)

-(NSString*)stringByReplacingHTMLTagAndTrim{
    NSString* str = [self stringByReplacingOccurrencesOfRegex:PATTERN 
                                                     withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
}

@end
