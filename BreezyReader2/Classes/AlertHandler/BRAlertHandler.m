//
//  BRAlertHandler.m
//  BreezyReader2
//
//  Created by 金 津 on 12-2-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRAlertHandler.h"
#import "BaseAlertView.h"
#import "BaseMessageView.h"
//#import "BaseImageScrollView.h"

@implementation BRAlertHandler

+(void)promptAlertString:(NSString*)alert{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self promptAlertString:alert type:BRAlertTypeAlert];
    });
}

+(void)promptAlertString:(NSString*)alert type:(BRAlertType)type{
    switch (type) {
        case BRAlertTypeAlert:
        {
            BaseAlertView* alertView = [[[NSBundle mainBundle] loadNibNamed:@"BaseAlertView" owner:nil options:nil] objectAtIndex:0];
            alertView.message = alert;
            [alertView show];
        }
            break;
        case BRAlertTypeMessage:
        {
            BaseMessageView* messageView = [[[NSBundle mainBundle] loadNibNamed:@"BaseMessageView" owner:nil options:nil] objectAtIndex:0];
            messageView.message = alert;
            [messageView show];
        }
            break;
        default:
            break;
    }
}


@end
