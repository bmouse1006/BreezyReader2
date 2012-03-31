//
//  NSObject+Notifications.m
//  BreezyReader2
//
//  Created by 金 津 on 12-2-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSObject+Notifications.h"

@implementation NSObject (Notifications)

-(void)registerNotifications{
    
}

-(void)unregisterNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
