//
//  MobWinAdRequest.h
//  MobWinSDK
//
//  Created by Guo Zhao on 11-9-26.
//  Copyright 2011 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MobWinAdRequest : NSObject

// 应用鉴权ID
//
// 详解：[必选]绑定应用的应用鉴权ID
@property (nonatomic, retain) NSString *adUnitID;

// 应用鉴权ID
//
// 详解：[必选]快捷方式，直接传入鉴权ID，发起广告请求
+ (MobWinAdRequest*)Request:(NSString*)adUnitID;

@end
