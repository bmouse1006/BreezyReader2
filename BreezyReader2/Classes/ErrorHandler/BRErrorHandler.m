//
//  BRErrorHandler.m
//  BreezyReader2
//
//  Created by 金 津 on 12-2-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRErrorHandler.h"
#import "BRAlertHandler.h"
#import "NSObject+Notifications.h"
#import "GoogleAppConstants.h"

@implementation BRErrorHandler

static BRErrorHandler* _handler;

+(id)sharedHandler{
    if (_handler == nil){
        _handler = [[self alloc] init];
    }
    
    return _handler;
}

-(id)init{
    self = [super init];
    if (self){
    }
    
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)registerAllErrorNotifications{
    [self registerNotifications];
}

-(void)registerNotifications{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(grErrorHappened:) name:GRERRORHAPPENED object:nil];
}

-(void)grErrorHappened:(NSNotification*)notification{
    NSDictionary* userInfo = notification.userInfo;
    NSString* errorMsg = [userInfo objectForKey:NSLocalizedDescriptionKey];
    [BRAlertHandler promptAlertString:errorMsg];
}

-(void)handleErrorMessage:(NSString*)message alert:(BOOL)alert{
    if (alert){
        [BRAlertHandler promptAlertString:message];
    }
}

@end
