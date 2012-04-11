//
//  GuoHeAdAdapter_MobWIN.h
//  GuoHeProiOSDev
//
//  Created by Mike Peng on 26/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHBaseAdapter.h"
#import "MobWinBannerView.h"
#import "MobWinAdRequest.h"

@interface GuoHeAdAdapter_MobWIN : GHBaseAdapter <UIGestureRecognizerDelegate>
{
    MobWinBannerView *_adBannerView;
    MobWinAdRequest *_adRequest;
    UITapGestureRecognizer *_nonListenerGR;
}

@property (nonatomic,retain) MobWinBannerView *adBannerView;

@end
