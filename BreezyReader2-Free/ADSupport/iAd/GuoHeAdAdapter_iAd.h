//
//  GuoHeAdAdapter_iAd.h
//  WeiboXL Lite
//
//  Created by Daniel on 11-3-8.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>
#import "GHBaseAdapter.h"


@interface GuoHeAdAdapter_iAd : GHBaseAdapter <ADBannerViewDelegate>{
	ADBannerView *_adBannerView;
}
@end
