//
//  GuoHeAdAdapter_Youmi.h
//  GuoHeSDKTest
//
//  Created by Daniel on 10-12-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHBaseAdapter.h"
#import "YouMiView.h"
#import "YouMiDelegateProtocol.h"

@class YouMiView;


@interface GuoHeAdAdapter_Youmi : GHBaseAdapter <YouMiDelegate> {
    YouMiView *_youMiView;
}

@property (nonatomic, retain) YouMiView *youMiView;

@end
