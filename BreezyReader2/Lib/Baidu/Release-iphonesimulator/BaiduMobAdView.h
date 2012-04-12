//
//  BaiduMobAdView.h
//  BaiduMobAdSdk
//
//  Created by jaygao on 11-9-6.
//  Copyright 2011年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaiduMobAdDelegateProtocol.h"

#define kBaiduAdViewSizeDefaultWidth 320
#define kBaiduAdViewSizeDefaultHeight 48

/**
 *  投放广告的视图接口,更多信息请查看[百度移动联盟主页](http://munion.baidu.com)
 */


@interface BaiduMobAdView : UIView {
    @private
    id<BaiduMobAdViewDelegate> delegate_;
    
    UIColor* textColor_;
    UIColor* backgroundColor_;
    CGFloat alpha_;
    BaiduMobAdViewType adType_;
    BOOL started_;
}


///---------------------------------------------------------------------------------------
/// @name 属性
///---------------------------------------------------------------------------------------

/**
 *  委托对象
 */
@property (nonatomic ,retain) id<BaiduMobAdViewDelegate>  delegate;

/**
 *  设置／获取当前广告（文字）的文本颜色
 */
@property (nonatomic, retain) UIColor* textColor;

/**
 *  设置／获取需要展示的广告类型
 */
@property (nonatomic) BaiduMobAdViewType AdType;

/**
 *  设置／获取是否启用广告展示动画
 */
@property (nonatomic) BOOL enableAdSwitchAnimiation;


/**
 *  获取广告视图的单例方法，在第一次创建BaiduMobAdView实例时调用
 */
+ (BaiduMobAdView*) sharedAdViewWithDelegate: (id<BaiduMobAdViewDelegate>) delegate;

/**
 *  获取广告视图的单例方法
 */
+ (BaiduMobAdView*) sharedAdView;


@end

