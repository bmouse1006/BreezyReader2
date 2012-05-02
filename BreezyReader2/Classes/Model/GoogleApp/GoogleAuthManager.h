//
//  GoogleAuthManager.h
//  BreezyReader
//
//  Created by Jin Jin on 10-5-31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleAppConstants.h"
#import "UserPreferenceDefine.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "ASIHTTPRequest.h"

#define LOGINSTATUS @"loginStatus"

#define AUTHINFOFILE		@"/ReaderAuthInfo.plist"

#define CAPTCHANEEDED @"captchaNeeded"
#define LOGINTOKEN @"loginToken"
#define LOGINCAPTCHA @"loginCaptcha"
#define CAPTCHAURL @"captchaURL"

@interface GoogleAuthManager : NSObject

@property (nonatomic, copy) NSError* error;
@property (nonatomic, copy, setter = setLoginStatus:) NSString* loginStatus;

@property (nonatomic, retain) GTMOAuth2Authentication* oauth;

+ (GoogleAuthManager*)shared;

-(void)logout;
-(void)reloginNeeded;
-(BOOL)canAuthorize;
-(BOOL)hadAuthorized:(NSURLRequest*)request;

-(NSMutableURLRequest*)URLRequestFromString:(NSString*)urlString;

-(UIViewController*)GOAuthController;

-(void)authRequest:(id)request;
-(void)authRequest:(id)request completionBlock:(void(^)(NSError*))block;

@end
