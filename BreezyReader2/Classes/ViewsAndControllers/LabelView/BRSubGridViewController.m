//
//  BRSubGridViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-2-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRSubGridViewController.h"
#import "BRSubGridViewDataSource.h"
#import "BRFeedViewController.h"
#import "UIViewController+BRAddition.h"
#import "UIViewController+addition.h"
#import "BRViewControllerNotification.h"
#import <mach/mach_time.h>
#import <QuartzCore/QuartzCore.h>

@interface BRSubGridViewController()

@property (nonatomic, assign) CGAffineTransform revertTransform;

@end

@implementation BRSubGridViewController

static CGFloat kTitleLabelHeight = 60.0f;

@synthesize tag = _tag, source = _source;
@synthesize titleLabel = _titleLabel;
@synthesize revertTransform = _revertTransform;

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSource:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)loadView{
    [super loadView];
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, kTitleLabelHeight);
    self.titleLabel = [[JJLabel alloc] initWithFrame:frame];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, [self thumbSpacing], 0, [self thumbSpacing]);
    [self.titleLabel setContentEdgeInsets:insets];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:32];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.shadowEnable = YES;
    self.titleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.titleLabel.shadowOffset = CGSizeMake(0, 2);
    self.titleLabel.shadowBlur = 4;
    [self.titleLabel addTarget:self action:@selector(didSelectTitleLabel:)];
    
    self.tableView.tableHeaderView = self.titleLabel;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createSource];
    [self assignMediaSource:self.source];
    // Do any additional setup after loading the view from its nib.
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.view.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = [self.source title];
    self.titleLabel.verticalAlignment = JJTextVerticalAlignmentMiddle;
//    CGFloat edgeHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat edgeHeight = 20.0f;
    UIEdgeInsets inset = UIEdgeInsetsMake(edgeHeight, 0, 0, 0);
    [self.tableView setContentInset:inset];
//    [self.source loadSourceMore:NO];
}

-(void)viewDidUnload{
    [super viewDidUnload];
    self.titleLabel = nil;
    self.tableView = nil;
    self.view = nil;
    self.source = nil;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.tableView.visibleCells  makeObjectsPerformSelector:@selector(willDisappear:) withObject:[NSNumber numberWithBool:animated]];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.tableView.visibleCells makeObjectsPerformSelector:@selector(didDisappear:) withObject:[NSNumber numberWithBool:animated]];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView.visibleCells makeObjectsPerformSelector:@selector(willAppear:) withObject:[NSNumber numberWithBool:animated]];
    [self.source loadSourceMore:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView.visibleCells makeObjectsPerformSelector:@selector(didAppear:) withObject:[NSNumber numberWithBool:animated]];
}

-(void)layoutTableView{
    //do nothing here
}

-(id<UITableViewDataSource>)generateDataSourceWithMediaSource:(id<JJMediaSource>)source{
    BRSubGridViewDataSource* datasource = [[BRSubGridViewDataSource alloc] initWithMediaSource:source delegate:self];
    [datasource setThumbSize:[self thumbSize] thumbSpacing:[self thumbSpacing]];
    return datasource;
}

-(void)mediaLibTableViewCell:(JJMediaLibTableViewCell *)cell didSelectMediaAtIndex:(NSInteger)index{
    GRSubscription* sub = [self.source mediaAtIndex:index];
    UIView* view = [cell.thumbnailViews objectAtIndex:index - [cell startIndex]];

    BRFeedViewController* feedController = [[BRFeedViewController alloc] initWithTheNibOfSameName];
    feedController.subscription = sub;
    
//    UINavigationController* nav = [[[UINavigationController alloc] initWithRootViewController:feedController] autorelease];
    
    [[self topContainer] boomOutViewController:feedController fromView:view];
}

-(void)sourceStartLoading{
    
}

-(void)sourceLoadFinished{
    [self.tableView reloadData];
}

-(CGFloat)thumbSize{
    return 123.0f;
}

-(CGFloat)thumbSpacing{
    return 7.0f;
}

-(void)createSource{
    self.source = [[BRSubGridSource alloc] init];
    self.source.tag = self.tag;
    self.source.delegate = self;
}

#pragma mark - notification call back
-(void)reloadSource:(NSNotification*)notification{
    [self.source loadSourceMore:NO];
}

#pragma mark - scroll view delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FORBIDDENFLIPANIMATION object:nil];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate == NO){
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ALLOWFLIPANIMATION object:nil];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ALLOWFLIPANIMATION object:nil];
}

#pragma mark - title label tap action
-(void)didSelectTitleLabel:(JJLabel*)titleLabel{
    if ([GoogleReaderClient tagWithID:self.tag.ID] == nil){
        return;
    };
    
    GRSubscription* sub = [self.tag toSubscription];
    BRFeedViewController* feedController = [[BRFeedViewController alloc] initWithTheNibOfSameName];
    feedController.subscription = sub;
    
    //    UINavigationController* nav = [[[UINavigationController alloc] initWithRootViewController:feedController] autorelease];
    
    [[self topContainer] boomOutViewController:feedController fromView:titleLabel];
}

@end
