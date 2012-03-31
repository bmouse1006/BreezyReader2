//
//  BROperationQueues.h
//  BreezyReader2
//
//  Created by  on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"

@interface BROperationQueues : NSObject

+(ASINetworkQueue*)sharedFeedQueue;

+(ASINetworkQueue*)sharedImgQueue;

@end
