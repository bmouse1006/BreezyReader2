//
//  BRImagePreviewCache.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRImagePreviewCache.h"

@interface BRImagePreviewCache (){
    NSMutableDictionary* _pool;
}

@end

@implementation BRImagePreviewCache

static BRImagePreviewCache* _shared;

+(id)sharedCache{
    if (_shared == nil){
        _shared = [[self alloc] init];
    }
    
    return _shared;
}

-(id)init{
    self = [super init];
    if (self){
        _pool = [[NSMutableDictionary dictionary] retain];
    }
    
    return self;
}

-(NSArray*)cachedPreviewImagesForKey:(NSString*)key{
    return [_pool objectForKey:key];
}

-(void)storeImagePreviews:(id)previews key:(NSString*)key{
    if (previews == nil){
        previews = [NSNull null];
    }
    if (key != nil){
        [_pool setObject:previews forKey:key];
    }
}

-(void)didReceiveMemoryWarning{
    [_pool removeAllObjects];
}

@end
