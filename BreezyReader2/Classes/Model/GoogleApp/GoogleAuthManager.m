//
//  GoogleAuthManager.m
//  BreezyReader
//
//  Created by Jin Jin on 10-5-31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GoogleAuthManager.h"
#import "CustomOAuth2ViewController.h"
#import "NSObject+Notifications.h"
#import "BRErrorHandler.h"

#define kKeychainItemName   @"BreezyReader2AuthKeyChainKey"
#define kOAuth2ClientID     @"976194106514.apps.googleusercontent.com"
#define kOAuth2ClientSecret @"66XPmD_hWWI6J4LqwcCS46_H"
#define kOAuth2RedirectURI  @"urn:ietf:wg:oauth:2.0:oob"
//#define kOAuth2Scope         @"https://www.google.com/reader/atom https://www.google.com/reader/api/"
#define kOAuth2Scope         @"https://www.google.com/reader/api/"

@interface GoogleAuthManager ()

-(void)promptAuthViewController;
-(ASIHTTPRequest*)ASIRequestFromString:(NSString*)urlString;

@end

@implementation GoogleAuthManager

@synthesize loginStatus = _loginStatus;

@synthesize oauth = _oauth;
@synthesize error = _error;

static GoogleAuthManager *shareAuthManager = nil;

#pragma mark - authorize

-(BOOL)canAuthorize{
    return [self.oauth canAuthorize];
}

-(void)reloginNeeded{
	[self logout];
	NSNotification* notification = [NSNotification notificationWithName:LOGINFAILED object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];

}

-(void)logout{
    
    [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.oauth];
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
    
    self.oauth = nil;
	self.loginStatus = LOGIN_NOTIN;
}

-(ASIHTTPRequest*)ASIRequestFromString:(NSString*)urlString{
	NSString* encodedURLString = [GOOGLE_SCHEME_SSL stringByAppendingString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	DebugLog(@"encoded URL String is %@", encodedURLString);
	//构造request
	NSURL* url = [NSURL URLWithString:encodedURLString];
	ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
	DebugLog(@"%@", [request description]);
    
	return request;
}

-(NSMutableURLRequest*)URLRequestFromString:(NSString*)urlString{
	//encode URL string
	NSString* googleScheme = nil;
	BOOL enableSSL = YES;
	if (enableSSL){
		googleScheme = GOOGLE_SCHEME_SSL;
	}else {
		googleScheme = GOOGLE_SCHEME;
	}

	NSString* encodedURLString = [googleScheme stringByAppendingString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	DebugLog(@"encoded URL String is %@", encodedURLString);
	//构造request
	NSURL* url = [NSURL URLWithString:encodedURLString];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
//    if ([self.oauth canAuthorize] == NO){
//        [self performSelectorOnMainThread:@selector(promptAuthViewController) withObject:nil waitUntilDone:NO];
//        
//        while([self.oauth canAuthorize] == NO && self.error == nil){
//            [[NSRunLoop currentRunLoop] runMode:NSRunLoopCommonModes beforeDate:[NSDate distantFuture]];
//        }	        
//        if (self.error){
//            //notify error happened
//            return nil;
//        }
//    }
    
//    [self.oauth authorizeRequest:request];
//    
//    if (self.error){
//        return nil;
//    }

	DebugLog(@"%@", [request description]);
	
	return request;
}

-(UIViewController*)GOAuthController{
    
    CustomOAuth2ViewController* authControl = [[CustomOAuth2ViewController alloc] initWithScope:kOAuth2Scope clientID:kOAuth2ClientID clientSecret:kOAuth2ClientSecret keychainItemName:kKeychainItemName completionHandler:^(GTMOAuth2ViewControllerTouch* viewController, GTMOAuth2Authentication* auth, NSError* error){
        if (error == nil){
            DebugLog(@"login succeded", nil);
            self.oauth = auth;
            self.loginStatus = LOGIN_SUCCESSFUL;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USERSIGNEDINFINISHED object:nil];
        }else{
            DebugLog(@"login failed", nil);
            DebugLog(@"%@", [error localizedDescription]);
            self.oauth = nil;
            self.loginStatus = LOGIN_FAILED;
        }
    }];
    return authControl;
}

-(void)promptAuthViewController{
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:[self GOAuthController]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentModalViewController:nav animated:YES];
}

#pragma mark - notification register and handlers
-(void)registerNotifications{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(startFetchAuthToken:) name:kGTMOAuth2FetchStarted object:nil];
    [nc addObserver:self selector:@selector(refreshTokenChanged:) name:kGTMOAuth2RefreshTokenChanged object:nil];
}

-(void)startFetchAuthToken:(NSNotification*)notification{
    DebugLog(@"start fetching auth token", nil);
}

-(void)stopFetchAuthToken:(NSNotification*)notification{
    DebugLog(@"stop fetching auth token", nil);
}
     
-(void)refreshTokenChanged:(NSNotification*)notification{
    DebugLog(@"auth token changed", nil);
}

#pragma mark - getter and setter

-(void)setLoginStatus:(NSString *)loginStatus{
    _loginStatus = [loginStatus copy];
    NSNotification* notification = [NSNotification notificationWithName:NOTIFICATION_LOGINSTATUSCHANGED object:nil userInfo:[NSDictionary dictionaryWithObject:self.loginStatus forKey:@"status"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(BOOL)authRequest:(id)request{
    return [self.oauth authorizeRequest:request];
}

-(void)authRequest:(id)request completionBlock:(void(^)(NSError*))block{
    [self.oauth authorizeRequest:request completionHandler:block];
}

-(void)authRequests:(NSArray*)requests completionBlock:(void(^)(NSError*))block{
    id request = [requests lastObject];
    if (request){
        [self authRequest:request completionBlock:^(NSError* error){
            if (!error){
                for (id req in requests){
                    [self authRequest:req];
                }
            }
            
            if (block){
                block(error);
            }
        }];
    }
}

#pragma mark - error handler

#pragma mark - init and dealloc

-(id)init{
    self = [super init];
    if (self){
        self.loginStatus = LOGIN_NOTIN;
        [self registerNotifications];
        self.oauth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kOAuth2ClientID clientSecret:kOAuth2ClientSecret];
    }
	return self;
}



#pragma mark - singleton methods

+ (GoogleAuthManager*)shared
{
    if (shareAuthManager == nil) {
        shareAuthManager = [[self alloc] init];
    }
    return shareAuthManager;
}

@end
