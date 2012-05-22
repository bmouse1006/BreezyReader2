//
//  JJSocialShareManager.m
//  SocialAuthTest
//
//  Created by Jin Jin on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJSocialShareManager.h"
#import <Twitter/Twitter.h>
//weibo header and define
#import "WBWeiboComposeViewController.h"
#import "ENNoteComposerController.h"
#import "SHK.h"
#import "SHKReadItLater.h"
#import "SHKFacebook.h"
#import "SHKInstapaper.h"
#import "SHKMail.h"

@interface JJSocialShareManager ()

@property (nonatomic, assign) id<JJSocialShareManagerDelegate> delegate;

@end

@implementation JJSocialShareManager

@synthesize delegate = _delegate;

static UIViewController* _rootViewController = nil;

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.delegate = nil;
    [super dealloc];
}

-(id)initWithDelegate:(id<JJSocialShareManagerDelegate>)delegate{
    self = [super init];
    if (self){
        _delegate = delegate;
    }
    
    return self;
}

+(id)sharedManager{
    static dispatch_once_t pred;
    __strong static JJSocialShareManager *obj = nil;     
    dispatch_once(&pred, ^{
        obj = [[JJSocialShareManager alloc] init];

    });     
    return obj;
}

+(id)managerWithDelegate:(id<JJSocialShareManagerDelegate>)delegate{
    JJSocialShareManager* manager = [[[JJSocialShareManager alloc] initWithDelegate:delegate] autorelease];
    
    return manager;
}

+(void)setRootViewController:(UIViewController*)rootViewController{  
    if (_rootViewController != rootViewController){
        [_rootViewController release];
        _rootViewController = [rootViewController retain];
    }
}

+(UIViewController*)rootViewController{
    if (!_rootViewController){
        return [UIApplication sharedApplication].keyWindow.rootViewController;
    }else{
        return _rootViewController;
    }
}


#pragma mark - send to interface
-(void)sendToWeiboWithMessage:(NSString*)message urlString:(NSString*)urlString image:(UIImage*)image{
    
    WBWeiboComposeViewController* controller = [WBWeiboComposeViewController controller];
    [controller addInitialText:message];
    [controller addImage:image];
    [controller addURLString:urlString];
    [controller show:YES];
}

-(void)sendToTwitterWithText:(NSString*)text urlString:(NSString*)urlString image:(UIImage*)image{
    TWTweetComposeViewController* controller = [[[TWTweetComposeViewController alloc] init] autorelease];
    [controller setInitialText:text];
    [controller addURL:[NSURL URLWithString:urlString]];
    [controller addImage:image];
    [[[self class] rootViewController] presentViewController:controller animated:YES completion:NULL];
}

-(void)sendToFacebookWithTitle:(NSString*)title message:(NSString*)message{
    [SHKFacebook shareItem:[self itemWithTitle:title message:message urlString:nil]];
}

-(void)sendToEvernoteWithTitle:(NSString*)title message:(NSString*)message urlString:(NSString *)urlString{
    ENNoteComposerController* controller = [[[ENNoteComposerController alloc] initWithNibName:@"ENNoteComposerController" bundle:nil] autorelease];
    [controller setENTitle:title];
    [controller setENContent:message];
    [controller setENURLString:urlString];
    UINavigationController* nav = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
    [[[self class] rootViewController] presentViewController:nav animated:YES completion:NULL];
}

-(void)sendToReadItLaterWithTitle:(NSString *)title message:(NSString *)message urlString:(NSString *)urlString{

    [SHKReadItLater shareItem:[self itemWithTitle:title message:message urlString:urlString]];
}

-(void)sendToInstapaperWithTitle:(NSString *)title message:(NSString *)message urlString:(NSString *)urlString{

    [SHKInstapaper shareItem:[self itemWithTitle:title message:message urlString:urlString]];
}

-(void)sendToMailWithTitle:(NSString*)title message:(NSString*)message urlString:(NSString*)urlString;{
    [SHKMail shareItem:[self itemWithTitle:title message:message urlString:urlString]];
}

-(SHKItem*)itemWithTitle:(NSString*)title message:(NSString*)message urlString:(NSString*)urlString{
    SHKItem *item = [[[SHKItem alloc] init] autorelease];
    item.title = title;
    item.text = message;
    item.URL = [NSURL URLWithString:urlString];
    item.shareType = SHKShareTypeText;
    return item;
}

#pragma mark - SHKSharerDelegate
-(void)sharerStartedSending:(SHKSharer *)sharer{
    if ([self.delegate respondsToSelector:@selector(shareManagerDidStartSharing:category:)]){
        [self.delegate shareManagerDidStartSharing:self category:[self categoryWithSharer:sharer]];
    }
}

-(void)sharerFinishedSending:(SHKSharer *)sharer{
    if ([self.delegate respondsToSelector:@selector(shareManagerDidFinishSharing:category:)]){
        [self.delegate shareManagerDidFinishSharing:self category:[self categoryWithSharer:sharer]];
    }
}

-(void)sharerCancelledSending:(SHKSharer *)sharer{
    if ([self.delegate respondsToSelector:@selector(shareManagerDidCancelSharing:category:)]){
        [self.delegate shareManagerDidCancelSharing:self category:[self categoryWithSharer:sharer]];
    }
}

-(void)sharer:(SHKSharer *)sharer failedWithError:(NSError *)error shouldRelogin:(BOOL)shouldRelogin{
    NSLog(@"error encountered while sharring: %@", [error localizedDescription]);
    if ([self.delegate respondsToSelector:@selector(shareManager:failedWithError:shouldRelogin:category:)]){
        [self.delegate shareManager:self failedWithError:error shouldRelogin:shouldRelogin category:[self categoryWithSharer:sharer]];
    }
}

#pragma mark - category
-(JJSocialShareCategory)categoryWithSharer:(SHKSharer*)sharer{
    if ([sharer isKindOfClass:[SHKFacebook class]]){
        return JJSocialShareCategoryFacebook;
    }
    
    if ([sharer isKindOfClass:[SHKReadItLater class]]){
        return JJSocialShareCategoryRIL;
    }
}

@end
