//
//  BRFeedConfigViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "UIViewController+BRAddtion.h"
#import "BRFeedConfigViewController.h"
#import "BRFeedControlViewController.h"
#import "BRRelatedFeedViewController.h"
#import "BRFeedDetailViewController.h"
#import "BRFeedLabelsViewController.h"
#import "BRViewControllerNotification.h"
#import "BRRelatedFeedViewController.h"

@interface BRFeedConfigViewController ()

@end

@implementation BRFeedConfigViewController

@synthesize subscription = _subscription;

@synthesize tableView = _tableView;
@synthesize feedOpertaionControllers = _feedOpertaionControllers;

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.feedOpertaionControllers = nil;
    self.subscription = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self registerNotifications];
    }
    return self;
}

-(void)registerNotifications{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(unsubscribeFeed:) name:NOTIFICATION_CONFIG_UNSUBSCRIBEFEED object:nil];
    [nc addObserver:self selector:@selector(renameFeed:) name:NOTIFICATION_CONFIG_RENAMEFEED object:nil];
    [nc addObserver:self selector:@selector(addTagToFeed:) name:NOTIFICATION_CONFIG_ADDTAG object:nil];
    [nc addObserver:self selector:@selector(removeTagFromFeed:) name:NOTIFICATION_CONFIG_REMOVETAG object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.feedOpertaionControllers = [NSMutableArray array];
    //add detail view controller
    BRFeedDetailViewController* detailController = [[[BRFeedDetailViewController alloc] initWithTheNibOfSameName] autorelease];
    detailController.subscription = self.subscription;
    BRFeedLabelsViewController* labelsController = [[[BRFeedLabelsViewController alloc] initWithTheNibOfSameName] autorelease];
    labelsController.subscription = self.subscription;
    BRFeedControlViewController* controlsController = [[[BRFeedControlViewController alloc] initWithTheNibOfSameName] autorelease];
    controlsController.subscription = self.subscription;
    BRRelatedFeedViewController* relatedFeedController = [[[BRRelatedFeedViewController alloc] initWithTheNibOfSameName] autorelease];
    relatedFeedController.subscription = self.subscription;
    [self.feedOpertaionControllers addObject:detailController];
    [self.feedOpertaionControllers addObject:labelsController];
    [self.feedOpertaionControllers addObject:relatedFeedController];
    [self.feedOpertaionControllers addObject:controlsController];
    //add labels view controller
    //add related feed view controller
    //add feed operation view controller
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.feedOpertaionControllers = nil;
}

-(void)viewWillLayoutSubviews{

}

#pragma mark - table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    BRFeedConfigBase* controller = [self.feedOpertaionControllers objectAtIndex:indexPath.section];
    return [controller heightOfRowAtIndex:indexPath.row];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    BRFeedConfigBase* controller = [self.feedOpertaionControllers objectAtIndex:section];
    return controller.sectionTitle;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    BRFeedConfigBase* controller = [self.feedOpertaionControllers objectAtIndex:section];
    return [controller sectionView];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    BRFeedConfigBase* controller = [self.feedOpertaionControllers objectAtIndex:section];
    return [controller heightForHeader];
}

#pragma mark - table view datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    BRFeedConfigBase* controller = [self.feedOpertaionControllers objectAtIndex:section];
    return [controller numberOfRowsInSection];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.feedOpertaionControllers count];
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BRFeedConfigBase* controller = [self.feedOpertaionControllers objectAtIndex:indexPath.section];
    return [controller cellForRow:indexPath.row];
}

#pragma mark - notification callback
-(void)unsubscribeFeed:(NSNotification*)notification{

}

-(void)renameFeed:(NSNotification*)notification{

}

-(void)addTagToFeed:(NSNotification*)notification{

}

-(void)removeTagFromFeed:(NSNotification*)notification{

}

@end
