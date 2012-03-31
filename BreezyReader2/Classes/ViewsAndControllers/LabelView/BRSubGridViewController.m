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
#import "UIViewController+BRAddtion.h"
#import "UIViewController+addition.h"
#import "BRViewControllerNotification.h"
#import <QuartzCore/QuartzCore.h>

@interface BRSubGridViewController()

@property (nonatomic, retain) UIViewController* boomedViewController;
@property (nonatomic, assign) CGAffineTransform revertTransform;

@end

@implementation BRSubGridViewController

static CGFloat kTitleLabelHeight = 60.0f;

@synthesize tag = _tag, source = _source;
@synthesize titleLabel = _titleLabel;
@synthesize boomedViewController = _boomedViewController;
@synthesize revertTransform = _revertTransform;

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.tag = nil;
    self.source = nil;
    self.titleLabel = nil;
    self.boomedViewController = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        NSNotification
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
    self.titleLabel = [[[JJLabel alloc] initWithFrame:frame] autorelease];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, [self thumbSpacing], 0, [self thumbSpacing]);
    [self.titleLabel setContentEdgeInsets:insets];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:32];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.shadowEnable = YES;
    self.titleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.titleLabel.shadowOffset = CGSizeMake(0, 2);
    self.titleLabel.shadowBlur = 4;
    
    self.tableView.tableHeaderView = self.titleLabel;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.delegate = self;
    self.view.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = self.tag.label;
    self.titleLabel.verticalAlignment = JJTextVerticalAlignmentMiddle;
    CGFloat edgeHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    UIEdgeInsets inset = UIEdgeInsetsMake(edgeHeight, 0, 0, 0);
    [self.tableView setContentInset:inset];
    self.source = [[[BRSubGridSource alloc] init] autorelease];
    self.source.label = self.tag.ID;
    self.source.delegate = self;
    [self assignMediaSource:self.source];
    [self.source loadSourceMore:NO];
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
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView.visibleCells makeObjectsPerformSelector:@selector(didAppear:) withObject:[NSNumber numberWithBool:animated]];
}

-(void)layoutTableView{
    //do nothing here
}

-(id<UITableViewDataSource>)generateDataSourceWithMediaSource:(id<JJMediaSource>)source{
    BRSubGridViewDataSource* datasource = [[[BRSubGridViewDataSource alloc] initWithMediaSource:source delegate:self] autorelease];
    [datasource setThumbSize:[self thumbSize] thumbSpacing:[self thumbSpacing]];
    return datasource;
}

-(void)mediaLibTableViewCell:(JJMediaLibTableViewCell *)cell didSelectMediaAtIndex:(NSInteger)index{
    GRSubscription* sub = [self.source mediaAtIndex:index];
    UIView* view = [cell.thumbnailViews objectAtIndex:index - [cell startIndex]];
    BRFeedViewController* feedController = [[[BRFeedViewController alloc] initWithTheNibOfSameName] autorelease];
    feedController.subscription = sub;
    
    UINavigationController* nav = [[[UINavigationController alloc] initWithRootViewController:feedController] autorelease];
    self.boomedViewController = nav;
    
    [[self topContainer] boomOutViewController:nav fromView:view];
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

@end
