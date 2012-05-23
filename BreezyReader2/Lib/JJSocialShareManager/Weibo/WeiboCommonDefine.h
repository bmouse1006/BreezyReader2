//
//  WeiboCommonDefine.h
//  SocialAuthTest
//
//  Created by Jin Jin on 12-5-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#define WeiboLocalizedString(key, comment) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:@"WeiboLocalizable"]