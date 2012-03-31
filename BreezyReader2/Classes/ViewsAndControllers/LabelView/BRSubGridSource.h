//
//  BRSubGridSource.h
//  BreezyReader2
//
//  Created by 金 津 on 12-2-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JJMediaLib.h"

@interface BRSubGridSource : NSObject<JJMediaSource>

@property (nonatomic, retain) NSString* label;
@property (nonatomic, retain) NSArray* subscriptions;
@property (nonatomic, assign) id<JJMediaSourceDelegate> delegate;

@end
