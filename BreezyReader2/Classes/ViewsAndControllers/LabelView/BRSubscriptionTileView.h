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

@property (nonatomic, readwrite) NSString* title;

@property (nonatomic, strong) IBOutlet JJLabel* caption;
@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UIButton* infoButton;
@property (nonatomic, strong) IBOutlet JJLabel* unreadLabel;

@property (nonatomic, setter = setImageURLs:) NSMutableArray* imageURLs;

@property (nonatomic, strong) GRSubscription* subscription;

-(void)switchSubviewFrom:(UIView*)original toView:(UIView*)destiny;

-(IBAction)infoButtonClicked:(id)sender;

@end
