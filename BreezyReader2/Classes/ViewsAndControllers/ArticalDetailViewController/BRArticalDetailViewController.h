//
//  BRArticalDetailViewController.h
//  BreezyReader2
//
//  Created by  on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRBaseController.h"
#import "GRFeed.h"

@interface BRArticalDetailViewController : BRBaseController<UIWebViewDelegate>

@property (nonatomic, retain) IBOutlet UIWebView* webView;
@property (nonatomic, retain) IBOutlet UIView* bottomToolBar;

@property (nonatomic, retain) GRFeed* feed;
@property (nonatomic, assign) NSUInteger index;

@property (nonatomic, retain) IBOutlet UIButton* backButton;

-(IBAction)back:(id)sender;
-(IBAction)scrollToTop:(id)sender;
-(IBAction)viewInSafari:(id)sender;

@end
