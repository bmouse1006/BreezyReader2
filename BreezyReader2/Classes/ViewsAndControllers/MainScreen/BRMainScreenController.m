//
//  BRMainScreenController.m
//  BreezyReader2
//
//  Created by 金 津 on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BRMainScreenController.h"
#import "MainScreenDataSource.h"
#import "GRDataManager.h"
#import "GoogleAuthManager.h"
#import "NSObject+Notifications.h"
#import "GoogleAppConstants.h"
#import "BRViewControllerNotification.h"
#import "BRFeedAndArticlesSearchController.h"
#import <QuartzCore/QuartzCore.h>

@interface BRMainScreenController (){
    BOOL _initialLoading;
}

@property (nonatomic, retain) MainScreenDataSource* dataSource;

-(void)recreateLayouts;

-(void)reload;

@end

@implementation BRMainScreenController

@synthesize infinityScroll = _infinityScroll;
@synthesize dataSource = _dataSource;

@synthesize labelViewControllers = _labelViewControllers;
@synthesize sideMenuController = _sideMenuController;

@synthesize searchController = _searchController;
@synthesize subOverrviewController = _subOverrviewController;

#pragma mark - init and dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.wantsFullScreenLayout = YES;
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    [[GRDataManager shared] reloadData_new];
    [self reload];
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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    [self.labelViewControllers makeObjectsPerformSelector:@selector(viewWillAppear:) withObject:[NSNumber numberWithBool:animated]];
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

#pragma mark - create subviews
-(void)recreateLayouts{
    //create scroll view, title label and control panel
    
}

#pragma mark - notifications register and handler
-(void)registerNotifications{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(syncBegan:) name:BEGANSYNCDATA object:nil];
    [nc addObserver:self selector:@selector(syncEnd:) name:ENDSYNCDATA object:nil];
    [nc addObserver:self selector:@selector(tagOrSubChanged:) name:TAGORSUBCHANGED object:nil];
    [nc addObserver:self selector:@selector(loginStatusChanged:) name:NOTIFICATION_LOGINSTATUSCHANGED object:nil];
    [nc addObserver:self selector:@selector(startFlipTile:) name:NOTIFICATION_STARTFLIPSUBTILEVIEW object:nil];
    [nc addObserver:self selector:@selector(showSearchUI:) name:NOTIFICATION_SERACHBUTTONCLICKED object:nil];
    [nc addObserver:self selector:@selector(finishedFlipTile:) name:NOTIFICATION_FINISHEDFLIPSUBTILEVIEW object:nil];
}

-(void)oauth2UserSignedIn:(NSNotification*)notification{
    //start to reload and fetch data
    DebugLog(@"user signed in", nil);
    [[GRDataManager shared] removeSavedFiles];
    [[GRDataManager shared] reloadData];
    //setup loading view
    _initialLoading = YES;
}

-(void)syncBegan:(NSNotification*)notification{
    DebugLog(@"start to sync reader data", nil);
}

-(void)syncEnd:(NSNotification*)notification{
    DebugLog(@"end of syncing reader data", nil);
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

#pragma mark - show search ui
-(void)showSearchUI:(NSNotification*)notification{
    [self.view addSubview:self.searchController.view];
    [self.searchController getReadyForSearch];
}

@end
