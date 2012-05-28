//
//  JJSocialShareManager.h
//  SocialAuthTest
//
//  Created by Jin Jin on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHKSharer.h"

typedef enum{
    JJSocialShareServiceWeibo,
    JJSocialShareServiceTwitter,
    JJSocialShareServiceFacebook,
    JJSocialShareServiceRIL,
    JJSocialShareServiceInstapaper,
    JJSocialShareServiceMail,
    JJSocialShareServiceGoogle,
    JJSocialShareServiceEvernote,
    JJSocialShareServiceUnknown
} JJSocialShareService;

@class JJSocialShareManager;

@protocol JJSocialShareManagerDelegate <NSObject>

@optional

-(void)shareManagerDidStartSharing:(JJSocialShareManager*)manager category:(JJSocialShareService)category;
-(void)shareManagerDidFinishSharing:(JJSocialShareManager*)manager category:(JJSocialShareService)category;
-(void)shareManagerDidCancelSharing:(JJSocialShareManager*)manager category:(JJSocialShareService)category;
-(void)shareManager:(JJSocialShareManager*)manager failedWithError:(NSError*)error shouldRelogin:(BOOL)shouldRelogin category:(JJSocialShareService)category;

@end

@interface JJSocialShareManager : NSObject<SHKSharerDelegate>

+(id)sharedManager;
+(void)setRootViewController:(UIViewController*)rootViewController;
+(id)managerWithDelegate:(id<JJSocialShareManagerDelegate>)delegate;

-(void)sendToWeiboWithMessage:(NSString*)message urlString:(NSString*)urlString image:(UIImage*)image;
-(void)sendToTwitterWithText:(NSString*)text urlString:(NSString*)urlString image:(UIImage*)image;
-(void)sendToFacebookWithTitle:(NSString*)title message:(NSString*)message;
-(void)sendToEvernoteWithTitle:(NSString*)title message:(NSString*)message urlString:(NSString*)urlString;
-(void)sendToReadItLaterWithTitle:(NSString*)title message:(NSString*)message urlString:(NSString*)urlString;
-(void)sendToInstapaperWithTitle:(NSString*)title message:(NSString*)message urlString:(NSString*)urlString;
-(void)sendToMailWithTitle:(NSString*)title message:(NSString*)message urlString:(NSString*)urlString;

-(BOOL)evernoteHandleOpenURL:(NSURL*)url;
-(BOOL)isServiceAutherized:(JJSocialShareService)service;
-(JJSocialShareService)serviceTypeForIdentifier:(NSString*)identifier;
-(void)logoutService:(JJSocialShareService)service;

@end
