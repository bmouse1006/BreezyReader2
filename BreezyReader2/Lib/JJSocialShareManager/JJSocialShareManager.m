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
#import "EvernoteSDK.h"
#import "GoogleAuthManager.h"

@interface JJSocialShareManager ()

@property (nonatomic, assign) id<JJSocialShareManagerDelegate> delegate;

@end

@implementation JJSocialShareManager

@synthesize delegate = _delegate;

static UIViewController* _rootViewController = nil;

+(void)initialize{
    [super initialize];
    // Do any additional setup after loading the view from its nib.
    NSString *EVERNOTE_HOST = @"www.evernote.com";
    
    // Fill in the consumer key and secret with the values that you received from Evernote
    // To get an API key, visit http://dev.evernote.com/documentation/cloud/
    NSString *CONSUMER_KEY = @"bmouse1006-3334";
    NSString *CONSUMER_SECRET = @"8efb9c47b2113834";
    
    // set up Evernote session singleton
    [EvernoteSession setSharedSessionHost:EVERNOTE_HOST 
                              consumerKey:CONSUMER_KEY 
                           consumerSecret:CONSUMER_SECRET];
}

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

-(BOOL)evernoteHandleOpenURL:(NSURL*)url{
    [ENNoteComposerController setStartHandleOpenURL:YES];
    return [[EvernoteSession sharedSession] handleOpenURL:url];
}

#pragma mark - send to interface
-(void)sendToWeiboWithMessage:(NSString*)message urlString:(NSString*)urlString image:(UIImage*)image{
    
    WBWeiboComposeViewController* controller = [WBWeiboComposeViewController sharedController];
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
//    if ([self.delegate respondsToSelector:@selector(shareManagerDidStartSharing:category:)]){
//        [self.delegate shareManagerDidStartSharing:self category:[self categoryWithSharer:sharer]];
//    }
}

-(void)sharerFinishedSending:(SHKSharer *)sharer{
//    if ([self.delegate respondsToSelector:@selector(shareManagerDidFinishSharing:category:)]){
//        [self.delegate shareManagerDidFinishSharing:self category:[self categoryWithSharer:sharer]];
//    }
}

-(void)sharerCancelledSending:(SHKSharer *)sharer{
//    if ([self.delegate respondsToSelector:@selector(shareManagerDidCancelSharing:category:)]){
//        [self.delegate shareManagerDidCancelSharing:self category:[self categoryWithSharer:sharer]];
//    }
}

-(void)sharer:(SHKSharer *)sharer failedWithError:(NSError *)error shouldRelogin:(BOOL)shouldRelogin{
//    NSLog(@"error encountered while sharring: %@", [error localizedDescription]);
//    if ([self.delegate respondsToSelector:@selector(shareManager:failedWithError:shouldRelogin:category:)]){
//        [self.delegate shareManager:self failedWithError:error shouldRelogin:shouldRelogin category:[self categoryWithSharer:sharer]];
//    }
}

#pragma mark - service
-(BOOL)isServiceAutherized:(JJSocialShareService)service{
    switch (service) {
        case JJSocialShareServiceRIL:
            return [SHKReadItLater isServiceAuthorized];
            break;
        case JJSocialShareServiceFacebook:
            return [SHKFacebook isServiceAuthorized];
            break;
        case JJSocialShareServiceMail:
            return [MFMailComposeViewController canSendMail];
            break;
        case JJSocialShareServiceWeibo:
            return [[WBWeiboComposeViewController sharedController] isAutherized];
            break;
        case JJSocialShareServiceTwitter:
            return [TWTweetComposeViewController canSendTweet];
            break;
        case JJSocialShareServiceInstapaper:
            return [SHKInstapaper isServiceAuthorized];;
            break;
        case JJSocialShareServiceGoogle:
            return [[GoogleAuthManager shared] canAuthorize];
            break;
        case JJSocialShareServiceEvernote:
            return [[EvernoteSession sharedSession] isAuthenticated];
            break;
        default:
            return NO;
            break;
    }
}

-(JJSocialShareService)serviceTypeForIdentifier:(NSString*)identifier{
    if ([identifier isEqualToString:@"google"]){
        return JJSocialShareServiceGoogle;
    }else if ([identifier isEqualToString:@"weibo"]){
        return JJSocialShareServiceWeibo;
    }else if ([identifier isEqualToString:@"readitlater"]){
        return JJSocialShareServiceRIL;
    }else if ([identifier isEqualToString:@"twitter"]){
        return JJSocialShareServiceTwitter;
    }else if ([identifier isEqualToString:@"facebook"]){
        return JJSocialShareServiceFacebook;
    }else if ([identifier isEqualToString:@"instapaper"]){
        return JJSocialShareServiceInstapaper;
    }else if ([identifier isEqualToString:@"mail"]){
        return JJSocialShareServiceMail;
    }else if ([identifier isEqualToString:@"evernote"]){
        return JJSocialShareServiceEvernote;
    }else{
        return JJSocialShareServiceUnknown;
    }
}

-(void)logoutService:(JJSocialShareService)service{
    switch (service) {
        case JJSocialShareServiceRIL:
            [SHKReadItLater logout];
            break;
        case JJSocialShareServiceFacebook:
            [SHKFacebook logout];
            break;
        case JJSocialShareServiceWeibo:
            [[WBWeiboComposeViewController sharedController] logout];
            break;
        case JJSocialShareServiceInstapaper:
            [SHKInstapaper logout];;
            break;
        case JJSocialShareServiceGoogle:
            [[GoogleAuthManager shared] logout];
            break;
        case JJSocialShareServiceEvernote:
            [[EvernoteSession sharedSession] logout];
            break;
        default:
            break;
    }
}

@end
