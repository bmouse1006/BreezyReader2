//
//  GuoHeAdAdapter_InMobi.h
//  GuoHeProiOSDev
//
//  Created by Daniel on 30/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHBaseAdapter.h"
#import "IMAdView.h"
#import "IMAdDelegate.h"
#import "IMAdRequest.h"
#import "IMAdError.h"

@interface GuoHeAdAdapter_InMobi : GHBaseAdapter <IMAdDelegate>{
    IMAdView *_adBannerView;
}

@property (nonatomic,retain) IMAdView *adBannerView;

@end
