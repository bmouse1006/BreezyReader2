//
//  BRSubscriptionTileView.h
//  BreezyReader2
//
//  Created by 金 津 on 12-2-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRSubscription.h"
#import "JJMediaThumbView.h"
#import "JJLabel.h"
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequestDelegate.h"

@interface BRSubscriptionTileView : UIControl<JJMediaThumbView, ASIHTTPRequestDelegate>

@property (nonatomic, readwrite, retain) NSString* title;

@property (nonatomic, retain) IBOutlet JJLabel* caption;
@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) IBOutlet UIButton* infoButton;
@property (nonatomic, retain) IBOutlet JJLabel* unreadLabel;

@property (nonatomic, retain, setter = setImageURLs:) NSMutableArray* imageURLs;

@property (nonatomic, retain) GRSubscription* subscription;

-(void)switchSubviewFrom:(UIView*)original toView:(UIView*)destiny;

-(IBAction)infoButtonClicked:(id)sender;

@end
