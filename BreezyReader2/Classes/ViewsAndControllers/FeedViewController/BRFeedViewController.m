//
//  BRFeedViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedViewController.h"
#import "BRArticleDetailViewController.h"
#import "BRArticleScrollViewController.h"
#import "BRViewControllerNotification.h"
#import "GoogleReaderClient.h"
#import "BRErrorHandler.h"
#import "BRADManager.h"

#define kFeedTableRowHeight 97

@interface BRFeedViewController (){
    BOOL _okToRefresh;
    BOOL _okToLoadMore;
    BOOL _isRefreshing;
    BOOL _isLoadingMore;
}

@property (nonatomic, assign) BOOL okToRefresh;
@property (nonatomic, assign) BOOL okToLoadMore;

@property (nonatomic, retain) GoogleReaderClient* client;

@property (nonatomic, retain) NSMutableSet* clients;
@property (nonatomic, retain) NSMutableDictionary* itemIDs;

-(void)startLoadingMore;
-(void)startRefreshing;
-(void)setupTableViewEdgeInsetByStatus;

@end

@implementation BRFeedViewController

@synthesize tableView = _tableView, dragController = _dragController;
@synthesize subscription = _subscription, dataSource = _dataSource;
@synthesize loadMoreController = _loadMoreController;
@synthesize loadingView = _loadingView;
@synthesize okToRefresh = _okToRefresh, okToLoadMore = _okToLoadMore;
@synthesize titleView = _titleView;
@synthesize bottomToolBar = _bottomToolBar;
@synthesize titleLabel = _titleLabel;
@synthesize loadingLabel = _loadingLabel;
@synthesize client = _client;
@synthesize clients = _clients, itemIDs = _itemIDs;

static CGFloat insetsTop = 0.0f;
static CGFloat insetsBottom = 0.0f;
static CGFloat refreshDistance = 60.0f;

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.tableView = nil;
    self.dragController = nil;
    self.subscription = nil;
    self.dataSource = nil;
    self.loadMoreController = nil;
    self.loadingView = nil;
    self.titleView = nil;
    self.bottomToolBar = nil;
    self.titleLabel = nil;
    self.loadingLabel = nil;
    [self.client clearAndCancel];
    self.client = nil;
    [[self.clients allObjects] makeObjectsPerformSelector:@selector(clearAndCancel)];
    self.clients = nil;
    self.itemIDs = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.wantsFullScreenLayout = YES;
        self.clients = [NSMutableSet set];
        self.itemIDs = [NSMutableDictionary dictionary];
        [self registerNotifications];
    }
    return self;
}

-(void)registerNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(starArticle:) name:NOTIFICATION_STARITEM object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unstarArticle:) name:NOTIFICATION_UNSTARITEM object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adLoaded:) name:NOTIFICATION_ADLOADED object:nil];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)willMoveToParentViewController:(UIViewController *)parent{
    if ([self isMovingToParentViewController] == NO){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
//    insetsTop = self.navigationController.navigationBar.frame.size.height;
    
    insetsTop = 0;
    insetsBottom = -self.loadMoreController.view.frame.size.height;
    self.title = self.subscription.title;
    self.tableView = [[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain] autorelease];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = kFeedTableRowHeight;
    UIPinchGestureRecognizer* gesture = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonClicked:)] autorelease];
    [self.tableView addGestureRecognizer:gesture];
    [self setupTableViewEdgeInsetByStatus];
    
    self.titleLabel.textColor = [UIColor darkGrayColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    self.titleLabel.verticalAlignment = JJTextVerticalAlignmentMiddle;
    self.titleLabel.text = self.title;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.titleView];
    [self.view addSubview:self.bottomToolBar];
    
    self.loadingLabel.font = [UIFont boldSystemFontOfSize:12];
    self.loadingLabel.textAlignment = UITextAlignmentCenter;
    self.loadingLabel.verticalAlignment = JJTextVerticalAlignmentMiddle;
    self.loadingLabel.textColor = [UIColor darkGrayColor];
    self.loadingLabel.text = NSLocalizedString(@"title_loading", nil);
    
    self.dragController.view.alpha = 0;
    self.dataSource = [[[BRFeedDataSource alloc] init] autorelease];
    self.dataSource.delegate = self;
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;
    // Do any additional setup after loading the view from its nib.
    self.dataSource.subscription = self.subscription;
    [self.dataSource loadDataMore:NO forceRefresh:NO];
    if ([self.dataSource isLoaded] == NO){
        [self.view addSubview:self.loadingView];
    }
    
    UIView* adView = [[BRADManager sharedManager] adView];
    if (adView){
        CGRect frame = adView.frame;
        frame.origin.x = 0;
        frame.origin.y = self.view.bounds.size.height-self.bottomToolBar.frame.size.height-frame.size.height;
        adView.frame = frame;
        [self.view addSubview:adView];
        [self.view bringSubviewToFront:self.bottomToolBar];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
    self.dragController = nil;
    self.dataSource = nil;
    self.loadingView = nil;
    self.loadMoreController = nil;
    self.titleLabel = nil;
    self.bottomToolBar = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidLayoutSubviews{
    
    CGRect frame = self.titleView.frame;
    frame.origin.y = 0;
    self.titleView.frame = frame;
    
    frame = self.bottomToolBar.frame;
    frame.origin.y = self.view.frame.size.height - self.bottomToolBar.frame.size.height;
    self.bottomToolBar.frame = frame;
    
    frame = self.tableView.frame;
    frame.origin.y = 0;
    frame.size.height = self.view.frame.size.height - self.bottomToolBar.frame.size.height;
    self.tableView.frame = frame;
    
    [self.view bringSubviewToFront:self.titleView];
    [self.view bringSubviewToFront:self.bottomToolBar];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    [[self.tableView visibleCells] makeObjectsPerformSelector:@selector(setNeedsLayout)];
    [self addHeaderAndFooterForTableView];
}

-(void)addHeaderAndFooterForTableView{
    self.tableView.tableFooterView = self.loadMoreController.view;
    [self.dragController.view removeFromSuperview];
    [self.tableView addSubview:self.dragController.view];
    CGRect frame = self.dragController.view.frame;
    frame.origin.y = -frame.size.height;
    self.dragController.view.frame = frame;
}

#pragma mark - setter and getter
-(void)setOkToRefresh:(BOOL)okToRefresh{
    if (_okToRefresh != okToRefresh){
        _okToRefresh = okToRefresh;
        if (_isRefreshing == YES){
            return;
        }
        if (_okToRefresh == YES){
            [self.dragController readyToRefresh];
        }else{
            [self.dragController pullToRefresh];
        }
    }
}

-(void)setOkToLoadMore:(BOOL)okToLoadMore{
    if (_okToLoadMore != okToLoadMore){
        _okToLoadMore = okToLoadMore;
        if (_isLoadingMore == YES){
            return;
        }
        if (_okToLoadMore == YES){
            [self startLoadingMore];
        }else{
            
        }
    }
}

#pragma mark - table view delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_isRefreshing){
        return;
    }
    CGPoint offset = scrollView.contentOffset;
    self.dragController.view.alpha = (offset.y + self.tableView.contentInset.top)/-refreshDistance;
    //drag to refresh
    if (offset.y + self.tableView.contentInset.top < -refreshDistance){
        DebugLog(@"it's time to refresh", nil);
        self.okToRefresh = YES;
    }else{
        self.okToRefresh = NO;
    }
    
    if (offset.y + self.tableView.frame.size.height + self.tableView.contentInset.top - self.tableView.contentSize.height + self.dragController.view.frame.size.height > 40){
        DebugLog(@"it's time to load more", nil);
        self.okToLoadMore = YES;
    }else{
        self.okToLoadMore = NO;
    }
    
    //pull to load more
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (![self.dataSource isLoading]){
        if (self.okToRefresh){
            [self startRefreshing];
        }else{
            [self.dragController pullToRefresh];
        }
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BRArticleScrollViewController* article = [[[BRArticleScrollViewController alloc] initWithTheNibOfSameName] autorelease];
    article.feed = self.dataSource.feed;
    article.index = indexPath.row;
    [[self topContainer] slideInViewController:article];
}

#pragma mark - action mathods
-(IBAction)backButtonClicked:(id)sender{
    [[self topContainer] boomInTopViewController];
}

-(IBAction)scrollToTop:(id)sender{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

#pragma mrak - data source delegate
-(void)dataSource:(BRBaseDataSource *)dataSource didFinishLoading:(BOOL)more{
    if (more){
        [self.loadMoreController stopLoadingWithMore:[self.dataSource hasMore]];
        _isLoadingMore = NO;
    }else{
        _isRefreshing = NO;
    }
    [self setupTableViewEdgeInsetByStatus];
    [self.dragController refreshLabels:self.dataSource.loadedTime];
    [self.tableView reloadData];
    [self addHeaderAndFooterForTableView];
    [UIView animateWithDuration:0.2 animations:^{
        self.loadingView.alpha = 0;
    } completion:^(BOOL finished){
        [self.loadingView removeFromSuperview];
    }];
}

-(void)dataSource:(BRBaseDataSource *)dataSource didStartLoading:(BOOL)more{
    if (more){
        //change appearnce of footer view
        [self.loadMoreController loadMore];
    }else{
        if ([self.dataSource isLoaded]){
            
        }else{
            [self.view addSubview:self.loadingView];
        }
    }
}
        
#pragma mark - refresh and loading more
-(void)startRefreshing{
    _isRefreshing = YES;
    [self.dragController refresh];
    //start refreshing
    [self.dataSource loadDataMore:NO forceRefresh:YES];
    [self setupTableViewEdgeInsetByStatus];
}

-(void)startLoadingMore{
    _isLoadingMore = YES;
    [self.loadMoreController loadMore];
    [self setupTableViewEdgeInsetByStatus];
    [self.dataSource loadDataMore:YES forceRefresh:NO];
}

#pragma mark - setup edge insets for table view
-(void)setupTableViewEdgeInsetByStatus{
    CGFloat top = insetsTop + self.titleView.frame.size.height;
    UIEdgeInsets tableInset = UIEdgeInsetsMake(top, 0, insetsBottom, 0);
    UIEdgeInsets indicatorInset = UIEdgeInsetsMake(top, 0, 0, 0);
    if (_isRefreshing){
        tableInset.top += refreshDistance;
    }
    if (_isLoadingMore){
        tableInset.bottom += 40;
    }
    [self.tableView setContentInset:tableInset];
    [self.tableView setScrollIndicatorInsets:indicatorInset];
}

#pragma mark - notification call back
-(void)starArticle:(NSNotification*)notification{  
    GoogleReaderClient* client = [GoogleReaderClient clientWithDelegate:self action:@selector(didReceiveStarResonponse:)];
    [self.clients addObject:client];
    NSString* itemID = [notification.userInfo objectForKey:@"itemID"];
    [self.itemIDs setObject:itemID forKey:[NSValue valueWithNonretainedObject:client]];
    [client starArticle:itemID];
}

-(void)unstarArticle:(NSNotification*)notification{
    GoogleReaderClient* client = [GoogleReaderClient clientWithDelegate:self action:@selector(didReceiveUnstarResponse:)];
    [self.clients addObject:client];
    NSString* itemID = [notification.userInfo objectForKey:@"itemID"];
    [self.itemIDs setObject:itemID forKey:[NSValue valueWithNonretainedObject:client]];
    [client unstartArticle:itemID];    
}

#pragma mark - google reader client call back
-(void)didReceiveStarResonponse:(GoogleReaderClient*)client{
    NSValue* key = [NSValue valueWithNonretainedObject:client];
    NSString* itemID = [self.itemIDs objectForKey:key];

    if (client.error == nil && client.isResponseOK){
        NSNotification* notification = [NSNotification notificationWithName:NOTIFICATION_STARSUCCESS object:itemID];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }else{
        //handle failure
        [[BRErrorHandler sharedHandler] handleErrorMessage:NSLocalizedString(@"msg_starfailed", nil) alert:YES];
        DebugLog(@"error is %@", [client.error localizedDescription]);
    }
    
    [self.itemIDs removeObjectForKey:key];
    [self.clients removeObject:client];
}

-(void)didReceiveUnstarResponse:(GoogleReaderClient*)client{
    NSValue* key = [NSValue valueWithNonretainedObject:client];
    NSString* itemID = [self.itemIDs objectForKey:key];
    
    if (client.isResponseOK){
        NSNotification* notification = [NSNotification notificationWithName:NOTIFICATION_UNSTARSUCCESS object:itemID];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }else{
        //handle failure
        [[BRErrorHandler sharedHandler] handleErrorMessage:NSLocalizedString(@"msg_unstarfailed", nil) alert:YES];
    }
    
    [self.itemIDs removeObjectForKey:key];
    [self.clients removeObject:client];    
}

//#pragma mark - ad view delegate
//-(void)adViewDidLoadAd:(GHAdView *)view{
//    view.hidden = NO;
//    CGRect frame = view.frame;
//    frame.origin.y = self.view.bounds.size.height - self.bottomToolBar.bounds.size.height - frame.size.height;
//    [UIView animateWithDuration:0.2 animations:^{
//        view.frame = frame; 
//    }];
//}
//
//-(void)adViewDidFailToLoadAd:(GHAdView *)view{
//    DebugLog(@"ad load failed");
//}
//
//-(UIViewController*)viewControllerForPresentingModalView{
//    return self;
//}

@end
