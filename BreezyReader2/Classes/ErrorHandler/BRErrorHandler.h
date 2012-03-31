//
//  BRErrorHandler.h
//  BreezyReader2
//
//  Created by 金 津 on 12-2-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRErrorHandler : NSObject

+(id)sharedHandler;

-(void)registerAllErrorNotifications;

-(void)handleErrorMessage:(NSString*)message alert:(BOOL)alert;

@end
