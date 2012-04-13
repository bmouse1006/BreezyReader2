//
//  MPSingleWebController.h
//  BreezyReader2
//
//  Created by  on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJSingleWebController : UIViewController<UIWebViewDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) IBOutlet UIWebView* webView;

@property (nonatomic, retain) NSURL* URL;

@end
