//
//  GuoHeAdAdapter_Millennial.h
//  GuoHeProiOSDev
//
//  Created by Mike Peng on 19/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMAdView.h"
#import "GHBaseAdapter.h"

@interface GuoHeAdAdapter_Millennial : GHBaseAdapter <MMAdDelegate, UIGestureRecognizerDelegate>
{
	MMAdView *_adBannerView;
    UITapGestureRecognizer *_nonListenerGR;
}

@property (nonatomic, retain) MMAdView *adBannerView;

@end
