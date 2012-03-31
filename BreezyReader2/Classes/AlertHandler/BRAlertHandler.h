//
//  BRAlertHandler.h
//  BreezyReader2
//
//  Created by 金 津 on 12-2-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    BRAlertTypeMessage,
    BRAlertTypeImage,
    BRAlertTypeAlert
} BRAlertType;

@interface BRAlertHandler : NSObject

+(void)promptAlertString:(NSString*)alert;
+(void)promptAlertString:(NSString*)alert type:(BRAlertType)type;

@end
