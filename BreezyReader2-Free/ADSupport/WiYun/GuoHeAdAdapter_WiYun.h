//
//  GuoHeAdAdapter_WiYun.h
//  GuoHeProiOSDev
//
//  Created by Wulin on 03/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHBaseAdapter.h"
#import "WiAdView.h"

@interface GuoHeAdAdapter_WiYun : GHBaseAdapter <WiAdViewDelegate,UIGestureRecognizerDelegate> {
    WiAdView *_adBannerView;
    UITapGestureRecognizer *_nonListenerGR;
}

@property (nonatomic, retain) WiAdView *adBannerView;

@end
