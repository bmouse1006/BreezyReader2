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

@property (nonatomic, strong) GRTag* tag;
@property (nonatomic, strong) NSArray* subscriptions;
@property (nonatomic, unsafe_unretained) id<JJMediaSourceDelegate> delegate;

@end
