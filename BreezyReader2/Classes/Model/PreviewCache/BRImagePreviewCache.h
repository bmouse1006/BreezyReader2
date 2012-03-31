//
//  BRImagePreviewCache.h
//  BreezyReader2
//
//  Created by 金 津 on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRImagePreviewCache : NSObject

+(id)sharedCache;

-(NSArray*)cachedPreviewImagesForKey:(NSString*)key;
-(void)storeImagePreviews:(id)previews key:(NSString*)key;
-(void)didReceiveMemoryWarning;

@end
