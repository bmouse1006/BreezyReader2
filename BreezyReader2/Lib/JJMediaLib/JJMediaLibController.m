//
//  JJMediaLibController.m
//  MeetingPlatform
//
//  Created by  on 12-2-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJMediaLibController.h"
#import "JJMediaLibTableViewCell.h"
#import "JJMedia.h"

static CGFloat kThumbSize = 75.0f;
static CGFloat kThumbSpacing = 4.0f;

@interface JJMediaLibController ()

-(void)layoutTableView;

@end

@implementation JJMediaLibController

@synthesize dataSource = _dataSource, mediaSource = _mediaSource;
@synthesize tableView = _tableView;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
	return [self initWithNibName:nil bundle:nil];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.wantsFullScreenLayout = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    
    return self;
}

-(void)dealloc{
    self.dataSource = nil;
    self.mediaSource = nil;
    self.tableView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)loadView{
//    [super loadView];
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.tableView = [[[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain] autorelease];
    self.tableView.rowHeight = [self rowHeight];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    [self layoutTableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.tintColor = nil;

}

-(void)viewDidUnload{
    [super viewDidUnload];
    self.tableView = nil;
    self.view = nil;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self layoutTableView];
    [self.tableView reloadData];
}

-(void)layoutTableView{
    UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat barsHeight = 20+44;
    if (UIInterfaceOrientationIsLandscape(orient)){
        barsHeight = 20+33;
    }
    self.tableView.contentInset = UIEdgeInsetsMake(barsHeight+4, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(barsHeight, 0, 0, 0);
}

#pragma mark delegate of cell view
-(void)mediaLibTableViewCell:(JJMediaLibTableViewCell *)cell didSelectMediaAtIndex:(NSInteger)index{
}

#pragma mark -- setter and getter
-(void)assignMediaSource:(id<JJMediaSource>)source{
    self.dataSource = [self generateDataSourceWithMediaSource:source];
    self.tableView.dataSource = self.dataSource;
    [self.tableView reloadData];
}

-(id<UITableViewDataSource>)generateDataSourceWithMediaSource:(id<JJMediaSource>)source{
    return [[[JJMediaDataSource alloc] initWithMediaSource:source delegate:self] autorelease];
}

-(CGFloat)thumbSize{
    return kThumbSize;
}
-(CGFloat)thumbSpacing{
    return kThumbSpacing;
}
-(CGFloat)rowHeight{
    return [self thumbSize] + [self thumbSpacing];
}

@end
