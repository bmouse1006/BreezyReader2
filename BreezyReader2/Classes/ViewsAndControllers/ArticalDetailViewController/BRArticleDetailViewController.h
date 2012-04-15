//
//  BRArticalDetailViewController.h
//  BreezyReader2
//
//  Created by  on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRBaseController.h"
#import "BRBottomToolBar.h"
#import "GRFeed.h"
#import "GRItem.h"

@interface BRArticleDetailViewController : BRBaseController<UIWebViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, retain) IBOutlet UIWebView* webView;
@property (nonatomic, retain) IBOutlet UIView* loadingView;
@property (nonatomic, retain) IBOutlet UILabel* loadingLabel;

@property (nonatomic, retain) GRItem* item;

-(id)initWithItem:(GRItem*)item;
-(void)scrollToTop;

-(void)increaseFontsize;
-(void)decreaseFontsize;

@end
