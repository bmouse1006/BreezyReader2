//
//  UIFont+simpleFormat.h
//  eManual
//
//  Created by  on 12-1-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSDate (simpleFormat)

-(NSString*)stringWithFormat:(NSString*)format;
-(NSString*)simpleDateString;
-(NSString*)shortString;

@end
