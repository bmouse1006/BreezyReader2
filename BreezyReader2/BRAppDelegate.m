//
//  BRAppDelegate.m
//  BreezyReader2
//
//  Created by 金 津 on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BRAppDelegate.h"
#import "BRMainScreenController.h"
#import "BRUserVerifyController.h"
#import "NSObject+Notifications.h"
#import "GoogleAppConstants.h"
#import "GoogleAuthManager.h"
#import "GRDataManager.h"
#import "BRAlertHandler.h"
#import "BRErrorHandler.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "BRTopContainer.h"
#import "BRADManager.h"

@interface BRAppDelegate ()

-(void)setupGlobalAppearence;

@property (nonatomic, retain) NSMutableSet* adSet;

@end

@implementation BRAppDelegate

@synthesize adSet = _adSet;
@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    self.adSet = nil;
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [[GRDataManager shared] readerDMSetup];
    //setup request cache
    [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
    [self registerNotifications];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];

    BRTopContainer* container = [[[BRTopContainer alloc] init] autorelease];
    BRMainScreenController* mainscreen = [[[BRMainScreenController alloc] init] autorelease];
    UINavigationController* nav = [[[UINavigationController alloc] initWithRootViewController:mainscreen] autorelease];
    [container addChildViewController:nav];
    
    if ([[GoogleAuthManager shared] canAuthorize] == NO){
        BRUserVerifyController* verifyController = [[[BRUserVerifyController alloc] init] autorelease];
        [container addChildViewController:verifyController];
    }
    self.window.rootViewController = container;
    //setup global appearence
    [self setupGlobalAppearence];
    
    [[BRErrorHandler sharedHandler] registerAllErrorNotifications];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [GoogleReaderClient invalideTimer];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [ASIHTTPRequest clearSession];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [self.window makeKeyAndVisible];
    if ([[GoogleAuthManager shared] canAuthorize]){
//        [[GoogleAuthManager shared] updateTokenAsync];
        [GoogleReaderClient refreshToken];
    }
    [GoogleReaderClient startTimerToRefreshToken];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
//    [ASIHTTPRequest clearSession];
}

#pragma mark - notification register and handler
-(void)registerNotifications{
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(logoutNeeded:) name:LOGOUTNEEDED object:nil];
}

-(void)logoutNeeded:(NSNotification*)notification{
    [[GoogleAuthManager shared] logout];
    BRUserVerifyController* verify = [[[BRUserVerifyController alloc] init] autorelease];
    [(BRTopContainer*)self.window.rootViewController addToTop:verify];
}

-(void)loginFailed:(NSNotification*)notification{
    //do nothing now
}

#pragma mark - appearence setup
-(void)setupGlobalAppearence{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav-bgImg"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[NSValue valueWithUIOffset:UIOffsetMake(0, 0)] forKey:UITextAttributeTextShadowOffset]];
    
    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"nav-bgImg"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    [[UISearchBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav-bgImg"]];
}

@end
