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
    
    BOOL _showMenu;
}

@property (nonatomic, assign) BOOL okToRefresh;
@property (nonatomic, assign) BOOL okToLoadMore;

@property (nonatomic, retain) GoogleReaderClient* client;

@property (nonatomic, retain) NSMutableSet* clients;
@property (nonatomic, retain) NSMutableDictionary* itemIDs;

@property (nonatomic, retain) UIView* adView;

-(void)startLoadingMore;
-(void)startRefreshing;
-(void)setupTableViewEdgeInsetByStatus;

@end

@implementation BRFeedViewController

@synthesize configViewController = _configViewController;
@synthesize tableView = _tableView, dragController = _dragController;
@synthesize actionMenuController = _actionMenuController;
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
@synthesize adView = _adView;
@synthesize menuButton = _menuButton;

static CGFloat insetsTop = 0.0f;
static CGFloat insetsBottom = 0.0f;
static CGFloat refreshDistance = 60.0f;

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.tableView = nil;
    self.dragController = nil;
    self.subscription = nil;
    self.actionMenuController = nil;
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
    self.adView = nil;
    self.menuButton = nil;
    self.configViewController = nil;
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
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(starArticle:) name:NOTIFICATION_STARITEM object:nil];
    [nc addObserver:self selector:@selector(unstarArticle:) name:NOTIFICATION_UNSTARITEM object:nil];
    [nc addObserver:self selector:@selector(markArticleAsRead:) name:NOTIFICATION_MARKITEMASREAD object:nil];
    [nc addObserver:self selector:@selector(markArticleAsUnread:) name:NOTIFICATION_MARKITEMASUNREAD object:nil];
    [nc addObserver:self selector:@selector(adLoaded:) name:NOTIFICATION_ADLOADED object:nil];
    [nc addObserver:self selector:@selector(markAllAsReadButtonClicked:) name:NOTIFICATION_MENUACTION_MARKALLASREAD object:nil];
    [nc addObserver:self selector:@selector(showUnreadOnly:) name:NOTIFICATION_MENUACTION_UNREADONLY object:nil];
    [nc addObserver:self selector:@selector(showAllArticles:) name:NOTIFICAITON_MENUACTION_ALLARTICLES object:nil];
    [nc addObserver:self selector:@selector(actionMenuDisappeared:) name:NOTIFICATION_MENUACTION_DISAPPEAR object:nil];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.configViewController.subscription = self.subscription;
    [self addChildViewController:self.configViewController];
//    insetsTop = self.navigationController.navigationBar.frame.size.height;
    
    insetsTop = 0;
    insetsBottom = -self.loadMoreController.view.frame.size.height;
    self.title = self.subscription.title;
    self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = kFeedTableRowHeight;
    UIPinchGestureRecognizer* gesture = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonClicked:)] autorelease];
    [self.tableView addGestureRecognizer:gesture];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_background_pattern"]];
    
    [self setupTableViewEdgeInsetByStatus];
    
    self.titleLabel.textColor = [UIColor darkGrayColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    self.titleLabel.verticalAlignment = JJTextVerticalAlignmentMiddle;
    self.titleLabel.text = self.title;
    UISwipeGestureRecognizer* swipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showConfigMenu)] autorelease];
    [self.titleLabel addGestureRecognizer:swipeLeft];
    
    [self.mainContainer addSubview:self.tableView];
    [self.mainContainer addSubview:self.titleView];
    
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
        [self.mainContainer addSubview:self.loadingView];
    }
    
    UIView* adView = [[BRADManager sharedManager] adView];
    if (adView){
        self.adView = adView;
        [self.mainContainer addSubview:adView];
    }
    
    [self.mainContainer addSubview:self.actionMenuController.view];
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
    self.adView = nil;
    self.menuButton = nil;
    self.actionMenuController = nil;
    self.configViewController = nil;
    [self.configViewController removeFromParentViewController];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGRect frame = self.titleView.frame;
    frame.origin.y = 0;
    self.titleView.frame = frame;
    
    frame = self.bottomToolBar.frame;
    frame.origin.y = self.mainContainer.frame.size.height - self.bottomToolBar.frame.size.height;
    self.bottomToolBar.frame = frame;
    
    frame = self.tableView.frame;
    frame.origin.y = 0;
    frame.origin.x = 0;
    frame.size.height = self.bottomToolBar.frame.origin.y;
    frame.size.width = self.mainContainer.bounds.size.width;
    self.tableView.frame = frame;
    
    frame = self.adView.frame;
    frame.origin.x = 0;
    frame.origin.y = self.mainContainer.bounds.size.height-self.bottomToolBar.frame.size.height-frame.size.height;
    self.adView.frame = frame;
    
    frame = self.actionMenuController.view.frame;
    frame.size.width = 165;
    frame.size.height = 137;
    self.actionMenuController.view.frame = frame;
    self.actionMenuController.view.hidden = YES;
    
    [self.mainContainer bringSubviewToFront:self.titleView];
    [self.mainContainer bringSubviewToFront:self.adView];
    [self.mainContainer bringSubviewToFront:self.actionMenuController.view];
    [self.mainContainer bringSubviewToFront:self.bottomToolBar];
}

-(void)secondaryViewWillShow{
    [self.configViewController viewWillAppear:YES];
}

-(void)secondaryViewDidShow{
    [self.configViewController viewDidAppear:YES];
}

-(void)secondaryViewWillHide{
    [self.configViewController viewWillDisappear:YES];
}

-(void)secondaryViewDidHide{
    [self.configViewController viewDidDisappear:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[self.tableView visibleCells] makeObjectsPerformSelector:@selector(setNeedsLayout)];
    [self.adView performSelector:@selector(resumeAdRequest)];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.adView performSelector:@selector(stopAdRequest)];
    [self.actionMenuController dismiss];
}

-(void)addHeaderAndFooterForTableView{
    self.tableView.tableFooterView = self.loadMoreController.view;
    [self.dragController.view removeFromSuperview];
    [self.tableView addSubview:self.dragController.view];
    CGRect frame = self.dragController.view.frame;
    frame.origin.y = -frame.size.height;
    self.dragController.view.frame = frame;
}

-(void)updateMenuButton{
    self.menuButton.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (_showMenu){
            self.menuButton.transform = CGAffineTransformMakeRotation(M_PI);
        }else{
            self.menuButton.transform = CGAffineTransformIdentity;        
        }
    } completion:^(BOOL finished){
        self.menuButton.userInteractionEnabled = YES;
    }];
}

-(void)showHideMenu{
    if (_showMenu){
        CGFloat x = self.mainContainer.frame.size.width - 3;
        CGFloat y = self.bottomToolBar.frame.origin.y - 3;
        [self.actionMenuController showMenuInPosition:CGPointMake(x, y) anchorPoint:CGPointMake(1, 1)];
    }else{
        [self.actionMenuController dismiss];
    }
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
    
    if (offset.y + self.tableView.frame.size.height + self.tableView.contentInset.top - self.tableView.contentSize.height + self.dragController.view.frame.size.height > 60){
        DebugLog(@"it's time to load more", nil);
        self.okToLoadMore = YES;
    }else{
        self.okToLoadMore = NO;
    }
    
    [self.actionMenuController dismiss];
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
-(IBAction)configButtonClicked:(id)sender{
    //insert menu to 
    [self showConfigMenu];
}

-(void)showConfigMenu{
    self.secondaryView = self.configViewController.view;
    [self slideShowSecondaryView];
}

-(IBAction)backButtonClicked:(id)sender{
    [[self topContainer] boomInTopViewController];
}

-(IBAction)scrollToTop:(id)sender{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

-(IBAction)showActionMenuButtonClicked:(id)sender{
    _showMenu = !_showMenu;
    [self showHideMenu];
    [self updateMenuButton];
    
}

#pragma mark - data source delegate
-(void)dataSource:(BRBaseDataSource *)dataSource didFinishLoading:(BOOL)more{
    if (more){
        [self.loadMoreController stopLoadingWithMore:[self.dataSource hasMore]];
        _isLoadingMore = NO;
    }else{
        _isRefreshing = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.loadingView.alpha = 0;
        } completion:^(BOOL finished){
            [self.loadingView removeFromSuperview];
        }];
    }
    [self setupTableViewEdgeInsetByStatus];
    [self.dragController refreshLabels:self.dataSource.loadedTime];
    [self.tableView reloadData];
    [self addHeaderAndFooterForTableView];
}

-(void)dataSource:(BRBaseDataSource *)dataSource didStartLoading:(BOOL)more{
    if (more){
        //change appearnce of footer view
        [self.loadMoreController loadMore];
    }else{
        if ([self.dataSource isLoaded]){
            
        }else{
            [self.mainContainer addSubview:self.loadingView];
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

-(void)markArticleAsRead:(NSNotification*)notification{
    GoogleReaderClient* client = [GoogleReaderClient clientWithDelegate:self action:@selector(didReceiveReadStatesChange:)];
    [self.clients addObject:client];
    NSString* itemID = [notification.userInfo objectForKey:@"itemID"];
    [self.itemIDs setObject:itemID forKey:[NSValue valueWithNonretainedObject:client]];
    [client markArticleAsRead:itemID];
}

-(void)markArticleAsUnread:(NSNotification*)notification{
    GoogleReaderClient* client = [GoogleReaderClient clientWithDelegate:self action:@selector(didReceiveReadStatesChange:)];
    [self.clients addObject:client];
    NSString* itemID = [notification.userInfo objectForKey:@"itemID"];
    [self.itemIDs setObject:itemID forKey:[NSValue valueWithNonretainedObject:client]];
    [client markArticleAsUnread:itemID];
}
     
-(void)markAllAsReadButtonClicked:(NSNotification*)notification{
    DebugLog(@"mark all as read", nil);
    GoogleReaderClient* client = [GoogleReaderClient clientWithDelegate:self action:@selector(didMarkAllAsReadReceived:)];
    [self.clients addObject:client];
    [client markAllAsRead:self.subscription.ID];    
}

-(void)showAllArticles:(NSNotification*)notification{
    self.dataSource.unreadOnly = NO;
    [self.dataSource loadDataMore:NO forceRefresh:NO];    
}

-(void)showUnreadOnly:(NSNotification*)notification{
    self.dataSource.unreadOnly = YES;
    [self.dataSource loadDataMore:NO forceRefresh:NO];
}

-(void)actionMenuDisappeared:(NSNotification*)notification{
    _showMenu = NO;
    [self updateMenuButton];
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

-(void)didReceiveReadStatesChange:(GoogleReaderClient*)client{
    NSValue* key = [NSValue valueWithNonretainedObject:client];
    NSString* itemID = [self.itemIDs objectForKey:key];
    
    if (client.isResponseOK){
        NSNotification* notification = [NSNotification notificationWithName:NOTIFICATION_READSTATESCHANGE object:itemID];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }else{
        //handle failure
//        [[BRErrorHandler sharedHandler] handleErrorMessage:NSLocalizedString(@"msg_networkerror", nil) alert:YES];
    }
    
    [self.itemIDs removeObjectForKey:key];
    [self.clients removeObject:client];   
}

-(void)didMarkAllAsReadReceived:(GoogleReaderClient*)client{
    
    if (client.isResponseOK){
        [self.tableView reloadData];
    }else{
        //handle failure
        [[BRErrorHandler sharedHandler] handleErrorMessage:NSLocalizedString(@"msg_operationfailed", nil) alert:YES];
    }
    
    [self.clients removeObject:client];  
}

@end
