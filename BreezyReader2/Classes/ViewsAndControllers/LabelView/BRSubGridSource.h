//
//  BRSubGridSource.h
//  BreezyReader2
//
//  Created by 金 津 on 12-2-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JJMediaLib.h"
#import "GRTag.h"

@interface BRSubGridSource : NSObject<JJMediaSource>

@property (nonatomic, retain) GRTag* tag;
@property (nonatomic, retain) NSArray* subscriptions;
@property (nonatomic, assign) id<JJMediaSourceDelegate> delegate;

@end
