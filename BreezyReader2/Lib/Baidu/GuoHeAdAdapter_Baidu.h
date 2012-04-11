//
//  GuoHeAdAdapter_Baidu.h
//  GuoHeProiOSDev
//
//  Created by Mike Peng on 23/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHBaseAdapter.h"
#import "BaiduMobAdView.h"

@interface GuoHeAdAdapter_Baidu : GHBaseAdapter <BaiduMobAdViewDelegate, UIGestureRecognizerDelegate>
{
    BaiduMobAdView *_adBannerView;
    NSString *theKey;
    NSString *theSpec;
    UITapGestureRecognizer *_nonListenerGR;
}

@property (nonatomic,retain) NSString *theKey;
@property (nonatomic,retain) NSString *theSpec;
@property (nonatomic,retain) BaiduMobAdView *adBannerView;

@end
