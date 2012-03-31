//
//  ImageFilter.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ImageFilter.h"

@implementation ImageFilter

+(BOOL)shouldFiltImage:(NSString*)imageURLString{
    NSRange range = [imageURLString rangeOfString:@"feedsportal.com"];
    if (range.location != NSNotFound){
        return YES;
    }
    return NO;
}

@end
