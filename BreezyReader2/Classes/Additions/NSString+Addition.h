//
//  NSString+Addition.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (addition)

-(NSString*)stringByReplacingHTMLTagAndTrim;

-(NSString*)stringByAddingPercentEscapesAndReplacingHTTPCharacter;

-(UIColor*)colorForString;

@end
