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

@property (nonatomic, strong) IBOutlet UIWebView* webView;
@property (nonatomic, strong) IBOutlet UIView* loadingView;
@property (nonatomic, strong) IBOutlet UILabel* loadingLabel;

@property (nonatomic, weak) id<UIScrollViewDelegate> delegate;

@property (nonatomic, strong) GRItem* item;

-(id)initWithItem:(GRItem*)item;
-(void)scrollToTop;

-(void)increaseFontsize;
-(void)decreaseFontsize;

@end
