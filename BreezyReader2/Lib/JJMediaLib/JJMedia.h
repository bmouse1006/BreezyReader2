//
//  JJMedia.h
//  BreezyReader2
//
//  Created by  on 12-2-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    JJMediaTypeImage,
    JJMediaTypeVedio,
    JJMediaTypeAudio,
    JJMediaTypeText,
    JJMediaTypeFlash
} JJMediaType;

@protocol JJMedia <NSObject>

-(NSString*)caption;
-(NSString*)thumbUrl;
-(NSString*)url;
-(JJMediaType)mediaType;

@end
