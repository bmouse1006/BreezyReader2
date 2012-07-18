//
//  SubOverviewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SubOverviewController.h"
#import "BRViewControllerNotification.h"
#import "UIView+util.h"
#import "GoogleReaderClient.h"
#import "BRImagePreviewCache.h"
#import <QuartzCore/QuartzCore.h>

@interface SubOverviewController ()

@property (nonatomic, strong) UIView* snapshot;
@property (nonatomic, assign) CGRect originalRect;
@property (nonatomic, strong) UIView* originalView;

@property (nonatomic, strong) GRSubscription* subscription;

@property (nonatomic, strong) NSString* velocity;
@property (nonatomic, strong) NSString* subscriberCount;

@property (nonatomic, strong) GoogleReaderClient* client;

-(void)updateSubDetail;

@end

@implementation SubOverviewController

@synthesize dimBackground = _dimBackground;
@synthesize container = _container;
@synthesize snapshot = _snapshot;
@synthesize dismissButton = _dismissButton;
@synthesize originalView = _originalView, originalRect = _originalRect;
@synthesize subDetailView = _subDetailView;
@synthesize subscription = _subscription;
@synthesize titleLabel = _titleLabel;
@synthesize subscriberCountLabel = _subscriberCountLabel;
@synthesize velocityLabel = _velocityLabel;
@synthesize velocity = _velocity;
@synthesize subscriberCount = _subscriberCount;
@synthesize client = _client;

static CGRect finalPosition = {60, 140, 200, 200};
static CGFloat animationDuration = 0.4f;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.wantsFullScreenLayout = YES;
    }
    
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.wantsFullScreenLayout = YES;
}

-(void)dealloc{
    [self.client clearAndCancel];
    self.subscription = nil;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.container.clipsToBounds = YES;
}

-(void)setSubscription:(GRSubscription *)subscription{
    if (_subscription != subscription){
        _subscription = subscription;
        [self updateSubDetail];
    }
}

-(void)showOverviewForSub:(GRSubscription*)sub inView:(UIView*)view flipFrom:(UIView*)originView{
    self.subscription = sub;
    
    [view addSubview:self.view];
    
    [self.client clearAndCancel];
    self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(didReceiveDetails:)];
    [self.client getStreamDetails:sub.ID];
    
    self.view.frame = view.bounds;
    self.dimBackground.alpha = 0.0f;
    self.originalView = originView;
    self.originalRect = [self.dimBackground convertRect:originView.bounds fromView:originView];
//    snapshot
    self.snapshot = [[UIImageView alloc] initWithImage:[self.originalView snapshot]];
    self.container.frame = self.originalRect;
    [self.container addSubview:self.snapshot];

    [self performSelector:@selector(startAnimation) withObject:nil afterDelay:0.1];

    [self updateSubDetail];
}

-(void)startAnimation{
    [self.container addSubview:self.subDetailView];
    
    [UIView transitionFromView:self.snapshot toView:self.subDetailView duration:animationDuration options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished){
        if (finished){
            [self.snapshot removeFromSuperview];
            self.container.layer.shadowColor = [UIColor blackColor].CGColor;
            self.container.layer.shadowOpacity = 0.7;
            self.container.layer.shadowRadius = 8.0;
            self.dismissButton.userInteractionEnabled = YES;
        }
    }];
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.dimBackground.alpha = 1.0f; 
        self.container.frame = finalPosition;
    }];
}

-(IBAction)dismiss:(id)sender{
    self.container.layer.shadowOpacity = 0.0f;
    self.dismissButton.userInteractionEnabled = NO;
    
    [UIView transitionFromView:self.subDetailView toView:self.snapshot duration:animationDuration options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished){
        if (finished){
            [self.view removeFromSuperview];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FINISHEDFLIPSUBTILEVIEW object:self.originalView];
        }
    }];
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.dimBackground.alpha = 0.0f; 
        self.container.frame = self.originalRect;
    }];
}

-(void)updateSubDetail{
    if (self.velocity == nil){
        self.velocity = @"";
    }
    
    if (self.subscriberCount == nil){
        self.subscriberCount = @"";
    }
    self.titleLabel.text = self.subscription.title;
    self.velocityLabel.text = [NSString stringWithFormat:NSLocalizedString(@"title_velocitylabel", nil), self.velocity];
    self.subscriberCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"title_subscribercount", nil), self.subscriberCount];
}

-(void)didReceiveDetails:(GoogleReaderClient*)client{
    if (client.error){
        NSLog(@"error message is %@", [client.error localizedDescription]);
    }else{
        DebugLog(@"%@", client.responseString);
        NSDictionary* json = client.responseJSONValue;
        self.velocity = [json objectForKey:@"velocity"];
        self.subscriberCount = [json objectForKey:@"subscribers"];
        [self updateSubDetail];
    }
}

@end
