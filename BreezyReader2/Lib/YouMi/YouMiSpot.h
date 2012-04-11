//
//  YouMiSpot.h
//  YouMiView
//
//  Created by Layne on 10-11-30.
//  Copyright 2010 www.youmi.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


// 插播向服务器请求需要展示的类型
typedef enum {
	YouMiSpotDisplayFormForRequestUnknow					= 0,	// 未知
	YouMiSpotDisplayFormForRequestLandscape                 = 1,	// 横屏
	YouMiSpotDisplayFormForRequestPortrait					= 2,	// 竖屏
	YouMiSpotDisplayFormForRequestLandscapeAndPortrait		= 3,	// 横屏+竖屏
} YouMiSpotDisplayFormForRequest;

// 显示插播广告的展示形式
typedef enum {
	YouMiSpotDisplayFormPortrait			= 1,
	YouMiSpotDisplayFormPortraitUpsideDown	= 2,
	YouMiSpotDisplayFormLandscapeRight		= 3,
	YouMiSpotDisplayFormLandscapeLeft		= 4
} YouMiSpotDisplayForm;

// 插播广告进度条样式
typedef enum {
	YouMiSpotProgressType1 = 1,
	YouMiSpotProgressType2 = 2,
	YouMiSpotProgressType3 = 3
} YouMiSpotProgressType;

// 插播广告展示的动画类型
typedef enum {
	YouMiSpotPresentType1	= 1,
	YouMiSpotPresentType2	= 2,
	YouMiSpotPresentType3	= 3,
	YouMiSpotPresentType4	= 4,
	YouMiSpotPresentType5	= 5
} YouMiSpotPresentType;


@protocol YouMiSpotDelegate;


@interface YouMiSpot : NSObject

// 开发者应用ID
// 
// 详解:前往有米主页:http://www.youmi.net/ 注册一个开发者帐户，同时注册一个应用，获取对应应用的ID
@property(nonatomic, copy)                      NSString    *appID;

// 开发者的安全密钥
// 
// 详解:前往有米主页:http://www.youmi.net/ 注册一个开发者帐户，同时注册一个应用，获取对应应用的安全密钥
@property(nonatomic, copy)                      NSString    *appSecret;

// 应用的版本信息
// @"1.0"
// 详解:返回开发者自己应用的版本信息
// 补充:返回的版本号需要使用浮点的类型,比如版本为1.0或者1.2等，目前服务器不支持1.1.1等版本的形式，有效低位版本只有一位，可以为1.12等
@property(nonatomic, copy)                      NSString    *appVersion;

// 应用发布的渠道号
// @1
// 详解:该参数主要给先推广该应用的时候，打包的渠道号
// 补充:可以渠道号 1 -> 255
@property(nonatomic, assign)                    NSInteger   channelID;

// 插播广告请求模式
// 模拟器@YES 真机器@NO
// 详解:广告请求的模式 [NO：正常模式 YES：测试模式] 
// 正常模式:按正常广告请求，记录展示和点击结果
// 测试模式:开始测试情况下请求，不记录展示和点击结果
// 备注:默认是模拟器是测试模式,真机是正常模式，若开发者在模拟器上面使用的时候，无法设置为正常模式
@property(nonatomic, assign, getter=isTesting)  BOOL        testing;


// 委托
@property(nonatomic, assign)id<YouMiSpotDelegate> delegate;


// 请求插播广告的将要展示的形式
// 
// 详解:1：横屏 2：竖屏 3：横屏或者竖屏
// 比如iPhone
// 1.横屏 --> 请求的插播广告大小尺寸是480x320，用于横屏显示
// 2.竖屏 --> 请求的插播广告大小尺寸是320x480，用于竖屏显示
// 3.横屏或者竖屏 --> 请求的插播广告大小尺寸是320x480 和 480x320，可以用于竖屏显示，也可以用于横屏显示
//
// 若应用只支持横屏模式，则返回1。若只支持竖屏模式，则返回2。若应用支持横屏和竖屏，则返回3
// 
// 备注:
// 该属性区别于YouMiSpot里面的显示插播广告的函数
// - (BOOL)showAdSpotWithDisplayForm:(YouMiSpotDisplayForm)displayForm
//                      progressType:(YouMiSpotProgressType)progressType
//                       presentType:(YouMiSpotPresentType)presentType
//                       promptTitle:(NSString *)title
// 该函数里面的YouMiSpotDisplayForm是显示插播广告的具体展示模式
// 而displayFormForSpotAd里面的返回的展示形式是要请求服务器的插播广告类型
// 若请求返回1[横屏]，则后面获取到的插播广告只能用YouMiSpotDisplayFormLandscapeRight或者YouMiSpotDisplayFormLandscapeLeft来显示
// 若请求返回2[竖屏]，则后面获取到的插播广告只能用YouMiSpotDisplayFormPortrait或者YouMiSpotDisplayFormPortraitUpsideDown来显示
// 若请求返回3[横屏或者竖屏]，则获取的插播广告内容是有横屏模式，也有竖屏模式，所以四种显示模式都可以显示
@property(nonatomic, assign) YouMiSpotDisplayFormForRequest displayFormForRequest;

// 请求插播广告允许的最小时间
// @3.0
// 详解:返回允许请求服务器目前可用插播广告的时间长度的最小值，默认是3秒
@property(nonatomic, assign) NSUInteger minAllowedTime;

// 请求插播广告允许的最大时间
// @10.0
// 详解:返回允许请求服务器目前可用插播广告的时间长度的最大值，默认是10秒
@property(nonatomic, assign) NSUInteger maxAllowedTime;


// iOS SDK Version
+ (NSString *)sdkVersion;

// 统计定位请求
// Default @YES
// 详解:返回时候运行使用GPS定位用户所在的坐标，主要是为了帮助开发者了解自己应用的分布情况，同时帮助精准投放广告需要
// [默认定位以帮助开发者了解自己软件精确投放广告]
+ (void)setShouldGetLocation:(BOOL)flag;

// 是否允许使用sqlite3来替用户保存一些下载的图片，以便节省用户的流量
// Default @YES
// 详解:帮助用户节省流量，同时加快广告显示速度
+ (void)setShouldCacheImage:(BOOL)flag;

// AdSpot的单实例
//
// 详解:返回一个YouMiSpot的单实例
+ (YouMiSpot *)sharedAdSpot;

// 开始请求插播广告
//
// 详解:入口函数，开始请求插播广告，当你设置完成后，务必记得调用该函数，以便通知后台开始请求服务器插播广告
-(void)startAdSpotRequest;

// 插播广告是否已经准备完毕
//
// 详解:每次调用showAdSpot之前请务必确认插播广告已经准备就绪
// 返回值:
//  YES->可以显示插播广告  
//  NO->插播广告当前还没有准备就绪，若调用showAdSpot则有可能无法正常显示
- (BOOL)isReadyForShow;

// 显示插播广告，若广告已经成功从服务器获取下来
// 
// 详解:调用该函数前，请务必确保之前已经开始请求广告
// 返回当前是否显示成功
// 参数->displayForm		: 显示插播广告的模式
// 参数->progressType	: 显示插播广告，表面浮动的进度条的类型
// 参数->presentType		: 显示插播广告，出现的动画类型[消失动画类型和出现动画类型匹配]
// 参数->title			: 显示插播广告，进度条上面的提示语言
- (BOOL)showAdSpotWithDisplayForm:(YouMiSpotDisplayForm)displayForm
					 progressType:(YouMiSpotProgressType)progressType
					  presentType:(YouMiSpotPresentType)presentType
					  promptTitle:(NSString *)title;

@end
