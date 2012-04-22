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

-(NSString*)shortString{
    NSDate* today = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"yyyy.MM.dd"];
    
    today = [formatter dateFromString:[formatter stringFromDate:today]];
    NSDate* dayOfDate = [formatter dateFromString:[formatter stringFromDate:self]];
    
    if ([today isEqualToDate:dayOfDate]){
        [formatter setDateFormat:@"HH:mm"];
    }else {
        [formatter setDateFormat:@"MM/dd"];
    }
    
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString* output = [formatter stringFromDate:self];
    [formatter release];
    
    return output;
}

@end
