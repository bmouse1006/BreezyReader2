//
//  BRMainScreenController.m
//  BreezyReader2
//
//  Created by 金 津 on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BRMainScreenController.h"
#import "MainScreenDataSource.h"
#import "GoogleAuthManager.h"
#import "NSObject+Notifications.h"
#import "GoogleAppConstants.h"
#import "BRViewControllerNotification.h"
#import "BRFeedAndArticlesSearchController.h"
#import "BRFeedViewController.h"
#import "GoogleReaderClient.h"
#import <QuartzCore/QuartzCore.h>

@interface BRMainScreenController (){
    BOOL _initialLoading;
}

@property (nonatomic, retain) MainScreenDataSource* dataSource;
@property (nonatomic, retain) GoogleReaderClient* client;

-(void)reload;

@end

@implementation BRMainScreenController

@synthesize infinityScroll = _infinityScroll;
@synthesize dataSource = _dataSource;

@synthesize labelViewControllers = _labelViewControllers;
@synthesize sideMenuController = _sideMenuController;

@synthesize searchController = _searchController;
@synthesize subOverrviewController = _subOverrviewController;

@synthesize client = _client;

#pragma mark - init and dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.wantsFullScreenLayout = YES;
        self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(clientFinished:)];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.client clearAndCancel];
    self.client = nil;
    self.infinityScroll = nil;
    self.sideMenuController = nil;
    self.dataSource = nil;
    self.labelViewControllers = nil;
    self.searchController = nil;
    self.subOverrviewController = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    [self.dataSource didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.infinityScroll = [[[InfinityScrollView alloc] initWithFrame:self.view.bounds] autorelease];
    self.dataSource = [[[MainScreenDataSource alloc] init] autorelease];
    self.infinityScroll.dataSource = self.dataSource;
    self.infinityScroll.infinityDelegate = self;
    self.infinityScroll.backgroundColor = [UIColor clearColor];

    CGRect menuRect = self.sideMenuController.view.frame;
    menuRect.size.height = self.view.bounds.size.height;
    menuRect.size.width = 60;
    menuRect.origin.x = self.view.bounds.size.width - menuRect.size.width;
    menuRect.origin.y = 0;
    [self.sideMenuController.view setFrame:menuRect];
    
    [self switchContentViewsToViews:[NSArray arrayWithObjects:self.infinityScroll, self.sideMenuController.view, nil] animated:YES];
    
    if ([GoogleReaderClient isReaderLoaded] == NO){
        [self.client refreshReaderStructure];
    }else{
        [self reload];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.infinityScroll = nil;
    self.view = nil;
    self.sideMenuController = nil;
    self.searchController = nil;
    self.subOverrviewController = nil;
//    self.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [UIApplication sharedApplication].statusBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
    [self.labelViewControllers makeObjectsPerformSelector:@selector(viewWillAppear:) withObject:[NSNumber numberWithBool:animated]];
    
    if ([self.client needRefreshUnreadCount]){
        [self.client refreshUnreadCount];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.labelViewControllers makeObjectsPerformSelector:@selector(viewDidAppear:) withObject:[NSNumber numberWithBool:animated]];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.labelViewControllers makeObjectsPerformSelector:@selector(viewWillDisappear:) withObject:[NSNumber numberWithBool:animated]];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.labelViewControllers makeObjectsPerformSelector:@selector(viewDidDisappear:) withObject:[NSNumber numberWithBool:animated]];
}

#pragma mark - notifications register and handler
-(void)registerNotifications{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(syncBegan:) name:NOTIFICATION_BEGIN_UPDATEREADERSTRUCTURE object:nil];
    [nc addObserver:self selector:@selector(syncEnd:) name:NOTIFICAITON_END_UPDATEREADERSTRUCTURE object:nil];
    [nc addObserver:self selector:@selector(tagOrSubChanged:) name:TAGORSUBCHANGED object:nil];
    [nc addObserver:self selector:@selector(loginStatusChanged:) name:NOTIFICATION_LOGINSTATUSCHANGED object:nil];
    [nc addObserver:self selector:@selector(startFlipTile:) name:NOTIFICATION_STARTFLIPSUBTILEVIEW object:nil];
    [nc addObserver:self selector:@selector(showSearchUI:) name:NOTIFICATION_SERACHBUTTONCLICKED object:nil];
    [nc addObserver:self selector:@selector(switchDownloadMode:) name:NOTIFICATION_DOWNLOADBUTTONCLICKED object:nil];
    [nc addObserver:self selector:@selector(showLogoutDialog:) name:NOTIFICATION_LOGOUTBUTTONCLICKED object:nil];
    [nc addObserver:self selector:@selector(showConfigUI:) name:NOTIFICATION_CONFIGBUTTONCLICKED object:nil];
    [nc addObserver:self selector:@selector(showStarItems:) name:NOTIFICATION_STARBUTTONCLICKED object:nil];
    [nc addObserver:self selector:@selector(showSubscriptionList:) name:NOTIFICATION_SHOWAUBLISTBUTTONCLICKED object:nil];
    [nc addObserver:self selector:@selector(finishedFlipTile:) name:NOTIFICATION_FINISHEDFLIPSUBTILEVIEW object:nil];
}

-(void)oauth2UserSignedIn:(NSNotification*)notification{
    //start to reload and fetch data
    DebugLog(@"user signed in", nil);
    [self.client refreshReaderStructure];
    //setup loading view
    _initialLoading = YES;
}

-(void)syncBegan:(NSNotification*)notification{
    DebugLog(@"start to sync reader data", nil);
}

-(void)syncEnd:(NSNotification*)notification{
    DebugLog(@"end of syncing reader data", nil);
    [self reload];
//    [self performSelectorOnMainThread:@selector(reload) withObject:nil waitUntilDone:NO];
}

-(void)tagOrSubChanged:(NSNotification*)notification{
    DebugLog(@"tag or sub changed", nil);
}

-(void)loginStatusChanged:(NSNotification*)notification{
    DebugLog(@"Login status changed", nil);
    NSString* status = [notification.userInfo objectForKey:@"status"];
    DebugLog(@"current login status is %@", status);
//    if ([status isEqualToString:LOGIN_NOTIN]){
//        [self switchContentViewsToViews:[NSArray arrayWithObject:self.signInButton] animated:YES];
//    }else if ([status isEqualToString:LOGIN_SUCCESSFUL]){
//        [self switchContentViewsToViews:[NSArray arrayWithObject:self.signoutButton] animated:YES];
//    }
}

-(void)startFlipTile:(NSNotification*)notification{
    DebugLog(@"start flip tile view");
    
    if (self.subOverrviewController == nil){
        self.subOverrviewController = [[[SubOverviewController alloc] initWithTheNibOfSameName] autorelease];
    }
    [self.subOverrviewController showOverviewForSub:[notification.userInfo objectForKey:@"subscription"] inView:self.view flipFrom:notification.object];
}

-(void)finishedFlipTile:(NSNotification*)notification{
    self.subOverrviewController = nil;
}

-(void)reload{
    [self.childViewControllers makeObjectsPerformSelector:@selector(viewWillDisappear:)];
    [self.dataSource reload];
    [self.infinityScroll reloadData];
    
    [self.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    [self.dataSource.controllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop){
        [self addChildViewController:obj];
    }];
    [self addChildViewController:self.searchController];
}
#pragma mark - delegate methods for infinity scroll view
-(void)scrollView:(InfinityScrollView *)scrollView didStopAtChildViewOfIndex:(NSInteger)index{
    //add more code here
}

-(void)scrollView:(InfinityScrollView *)scrollView userDraggingOffset:(CGPoint)offset{
    //do nothing
}

-(void)scrollViewDidScroll:(InfinityScrollView*)scrollView{

}

#pragma mark - NOTIFICATOIN call back
-(void)showSearchUI:(NSNotification*)notification{
    [self.view addSubview:self.searchController.view];
    [self.searchController getReadyForSearch];
//    [[self topContainer] addToTop:self.searchController animated:YES];
}

-(void)showStarItems:(NSNotification*)notification{
    BRFeedViewController* starFeed = [[[BRFeedViewController alloc] initWithTheNibOfSameName] autorelease];
    starFeed.subscription = [GRSubscription subscriptionForLabel:[GoogleReaderClient starTag]];
    starFeed.subscription.title = NSLocalizedString(@"title_starred", nil);
    [[self topContainer] boomOutViewController:starFeed fromView:notification.object];
}

-(void)showSubscriptionList:(NSNotification*)notification{
    
}

-(void)switchDownloadMode:(NSNotification*)notification{
    DebugLog(@"switch download mode");
}

-(void)showLogoutDialog:(NSNotification*)notification{
    DebugLog(@"show logout dialog");
}

-(void)showConfigUI:(NSNotification*)notification{
    DebugLog(@"show config UI");
}

#pragma mark - reader client call back
-(void)clientFinished:(GoogleReaderClient*)client{
    if (client.error){
        //handle error
        DebugLog(@"error happened %@", [client.error localizedDescription]);
    }
}

@end
