//
//  BRFeedViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedViewController.h"
#import "BRArticalDetailViewController.h"
#import "BRViewControllerNotification.h"

#define kFeedTableRowHeight 97

@interface BRFeedViewController (){
    BOOL _okToRefresh;
    BOOL _okToLoadMore;
    BOOL _isRefreshing;
    BOOL _isLoadingMore;
}

@property (nonatomic, assign) BOOL okToRefresh;
@property (nonatomic, assign) BOOL okToLoadMore;

-(void)startLoadingMore;
-(void)startRefreshing;
-(void)setupTableViewEdgeInsetByStatus;

@end

@implementation BRFeedViewController

@synthesize tableView = _tableView, dragController = _dragController, backButton = _backButton;
@synthesize subscription = _subscription, dataSource = _dataSource;
@synthesize loadMoreController = _loadMoreController;
@synthesize loadingView = _loadingView;
@synthesize okToRefresh = _okToRefresh, okToLoadMore = _okToLoadMore;
@synthesize activityView = _activityView;

static CGFloat insetsTop = 0.0f;
static CGFloat insetsBottom = 0.0f;
static CGFloat refreshDistance = 60.0f;

-(void)dealloc{
    self.tableView = nil;
    self.dragController = nil;
    self.subscription = nil;
    self.dataSource = nil;
    self.backButton = nil;
    self.loadMoreController = nil;
    self.loadingView = nil;
    self.activityView = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.wantsFullScreenLayout = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)viewWillLayoutSubviews{
    for (UIView* subview in self.view.subviews){
        DebugLog(@"%@", subview.description);
    }
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
    [self.activityView startAnimating];
    
    insetsTop = 0;
    insetsBottom = -self.loadMoreController.view.frame.size.height;
    self.title = self.subscription.title;
    self.tableView = [[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain] autorelease];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = self.loadMoreController.view;
    [self.tableView addSubview:self.dragController.view];
    self.tableView.rowHeight = kFeedTableRowHeight;
    UIPinchGestureRecognizer* gesture = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonClicked:)] autorelease];
    [self.tableView addGestureRecognizer:gesture];
    [self setupTableViewEdgeInsetByStatus];
    
    [self.view addSubview:self.tableView];
    CGRect frame = self.view.bounds;
    frame.origin.y -= frame.size.height;
    [self.dragController.view setFrame:frame];
    self.dragController.view.alpha = 0;
    self.dataSource = [[[BRFeedDataSource alloc] init] autorelease];
    self.dataSource.delegate = self;
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.backButton] autorelease];
    // Do any additional setup after loading the view from its nib.
    self.dataSource.subscription = self.subscription;
    [self.dataSource loadDataMore:NO forceRefresh:NO];
    if ([self.dataSource isLoaded] == NO){
        [self.view addSubview:self.loadingView];
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
    self.dragController = nil;
    self.dataSource = nil;
    self.backButton = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    BRArticalDetailViewController* detail = [[[BRArticalDetailViewController alloc] initWithTheNibOfSameName] autorelease];
    detail.feed = self.dataSource.feed;
    detail.index = indexPath.row;
    UINavigationController* nav = [[[UINavigationController alloc] initWithRootViewController:detail] autorelease];
    [[self topContainer] boomOutViewController:nav fromView:[tableView cellForRowAtIndexPath:indexPath]];
//    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - action mathods
-(IBAction)backButtonClicked:(id)sender{
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_VIEWCONTROLLER_BOOMIN object:self];
    [[self topContainer] boomInTopViewController];
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
    [self.loadingView removeFromSuperview];
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
    UIEdgeInsets tableInset = UIEdgeInsetsMake(insetsTop, 0, insetsBottom, 0);
    UIEdgeInsets indicatorInset = UIEdgeInsetsMake(insetsTop, 0, 0, 0);
    if (_isRefreshing){
        tableInset.top += refreshDistance;
    }
    if (_isLoadingMore){
        tableInset.bottom += 40;
    }
    [self.tableView setContentInset:tableInset];
    [self.tableView setScrollIndicatorInsets:indicatorInset];
}

@end
