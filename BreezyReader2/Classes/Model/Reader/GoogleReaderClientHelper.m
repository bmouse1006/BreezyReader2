//
//  GoogleReaderClientHelper.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GoogleReaderClientHelper.h"

@interface GoogleReaderClientHelper()

@property (nonatomic, strong) NSMutableArray* clientQueue;

@end

@implementation GoogleReaderClientHelper

@synthesize clientQueue = _clientQueue;

-(id)init{
    self = [super init];
    if (self){
        self.clientQueue = [NSMutableArray array];
    }
    
    return self;
}

-(void)dealloc{
    [self.clientQueue makeObjectsPerformSelector:@selector(clearAndCancel)];
}

+(id)sharedHelper{
    static dispatch_once_t predHelper;
    static GoogleReaderClientHelper* _sharedHelper = nil;
    
    dispatch_once(&predHelper, ^{ 
        _sharedHelper = [[GoogleReaderClientHelper alloc] init]; 
    }); 
    
    return _sharedHelper;
}

+(GoogleReaderClient*)client{
    GoogleReaderClientHelper* helper = [self sharedHelper];
    GoogleReaderClient* client = [GoogleReaderClient clientWithDelegate:helper action:@selector(clientDidFinish:)];
    [helper.clientQueue addObject:client];
    return client;
}

-(void)clientDidFinish:(GoogleReaderClient*)client{
    DebugLog(@"response of google reader client is %@", client.responseString);
    [self.clientQueue removeObject:client];
}

@end
