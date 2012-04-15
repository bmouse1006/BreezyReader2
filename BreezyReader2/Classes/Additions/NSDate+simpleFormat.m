//
//  UIFont+simpleFormat.m
//  eManual
//
//  Created by  on 12-1-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSDate+simpleFormat.h"

@implementation NSDate (simpleFormat)

-(NSString*)stringWithFormat:(NSString*)format{
    NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:self];
}

-(NSString*)simpleDateString{
    return [self stringWithFormat:@"yyyy-MM-dd"];
}

@end
