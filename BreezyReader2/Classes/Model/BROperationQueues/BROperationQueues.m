//
//  BROperationQueues.m
//  BreezyReader2
//
//  Created by  on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BROperationQueues.h"
#import "ASINetworkQueue.h"

@implementation BROperationQueues

static ASINetworkQueue* _feedQueue = nil;
static ASINetworkQueue* _imgQueue = nil;

+(ASINetworkQueue*)sharedFeedQueue{
    if (_feedQueue == nil){
        _feedQueue = [[ASINetworkQueue alloc] init];
        [_feedQueue setShouldCancelAllRequestsOnFailure:NO];
    }
    
    return _feedQueue;
}

+(ASINetworkQueue*)sharedImgQueue{
    if (_imgQueue){
        _imgQueue = [[ASINetworkQueue alloc] init];
        [_imgQueue setShouldCancelAllRequestsOnFailure:NO];
    }
    
    return _imgQueue;
}

@end
