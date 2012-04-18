//
//  MobWinBannerView.h
//  MobWinSDK
//
//  Created by Guo Zhao on 10/28/11.
//  Copyright (c) 2011 Tencent. All rights reserved.
//

#import "MobWinBannerView.h"

@class MobWinAdRequest;

typedef enum {
    MobWINBannerSizeIdentifierUnknow     = 0,
    MobWINBannerSizeIdentifier320x50     = 1, // iPhone/iPod Touch广告
    MobWINBannerSizeIdentifier300x250    = 2, // IAB页首条幅 iPad广告
    MobWINBannerSizeIdentifier468x60     = 3, // IAB标准条幅 iPad广告
    MobWINBannerSizeIdentifier728x90     = 4  // IAB中灯矩形 iPad广告
} MobWinBannerSizeIdentifier;

@interface MobWinBannerView : UIView

// 父视图
// 详解：[必选]需设置为显示广告的UIViewController
@property (nonatomic, retain) UIViewController *rootViewController;


// 广告条初始化请求
// 
// 详解：[必选]需传入广告条尺寸参数，生成对应广告栏
- (id)initMobWinBannerSizeIdentifier:(MobWinBannerSizeIdentifier)sizeIdentifier;


// 广告发起请求方法
// 
// 详解：[必选]需传入请求句柄，发起拉取广告请求
- (void)startRequest:(MobWinAdRequest*)adReq;


// 广告停止请求方法
//
// 详解：[必选]停止拉取广告请求，禁止页面退出后的无效广告请求
- (void)stopRequest;


// 测试模式开关
// 默认测试模式关闭 adTestMode == NO
//
// 详解：[可选]测试模式开关，YES为测试模式，NO为发布模式，提交应用审核时请设置此参数为NO
@property (nonatomic, assign) bool adTestMode; 


// GPS精准广告定位模式开关
// 默认Gps模式开启 adGpsMode == YES
//
// 详解：[可选]精准定位模式开关，YES为精准定位模式，NO为非精准定位模式，建议设为精准定位模式，可以获取地域精准定向广告，提高广告的填充率，增加收益。
@property (nonatomic, assign) bool adGpsMode; 


// 广告播放时间
// 默认30秒，有效范围30秒～200秒
//
// 详解：[可选]广告的播放时间
@property (nonatomic, assign) int adRefreshInterval;


// 推广标题文本颜色
// @{255/255.0, 255/255.0, 255/255.0, 1.0}
//
// 详解：[可选]广告推广标题文本颜色
@property(nonatomic, retain) UIColor *adTextColor;


// 推广语文本颜色
// @{255/255.0, 255/255.0, 255/255.0, 1.0}
//
// 详解：[可选]广告推广语文本颜色，针对纯文字广告的小字体
@property(nonatomic, retain) UIColor *adSubtextColor;


// 广告条背景颜色
// @{2.0/255.0, 12.0/255.0, 15.0/255.0, 1.0}
//
// 详解：[可选]广告条背景颜色
@property(nonatomic, retain) UIColor *adBackgroundColor;


// 广告条透明度
// 默认90%，有效范围60%～90%
//
// 详解：[可选]广告条背景的透明度
@property(nonatomic, assign) CGFloat adAlpha; 

@end
