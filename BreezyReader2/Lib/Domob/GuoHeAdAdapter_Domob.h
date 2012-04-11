//
//  GuoHeAdAdapter_Domob.h
//  TestGuoHeAd1
//
//  Created by Daniel on 11-5-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHBaseAdapter.h"
#import "DoMobView.h"
#import "DoMobDelegateProtocol.h"

@interface GuoHeAdAdapter_Domob : GHBaseAdapter <DoMobDelegate, UIGestureRecognizerDelegate> {
    DoMobView *_doMobView;
    NSString *_publishID;
    NSString *_testOrNot;
    UITapGestureRecognizer *_nonListenerGR;
}
@property (nonatomic,retain) NSString *publishID;
@property (nonatomic,retain) NSString *testOrNot;
@property (nonatomic,retain) DoMobView *doMobView;
@end
