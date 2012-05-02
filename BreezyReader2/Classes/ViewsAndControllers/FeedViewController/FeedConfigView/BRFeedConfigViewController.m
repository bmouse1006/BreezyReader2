//
//  BRFeedConfigViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "UIViewController+BRAddtion.h"
#import "BRFeedConfigViewController.h"
#import "BRFeedControlViewSource.h"
#import "BRRelatedFeedViewSource.h"
#import "BRFeedDetailViewSource.h"
#import "BRFeedLabelsViewSource.h"
#import "BRViewControllerNotification.h"
#import "BRRelatedFeedViewSource.h"
#import "BRFeedViewController.h"
#import "GoogleReaderClient.h"
#import "BaseActivityLabel.h"

@interface BRFeedConfigViewController ()

@property (nonatomic, retain) GoogleReaderClient* client;
@property (nonatomic, retain) BaseActivityLabel* activityLabel;
@property (nonatomic, retain) NSTimer* timer;

@end

@implementation BRFeedConfigViewController

@synthesize timer = _timer;

@synthesize subscription = _subscription;

@synthesize tableView = _tableView;
@synthesize feedOpertaionControllers = _feedOpertaionControllers;

@synthesize client = _client;
@synthesize activityLabel = _activityLabel;

#define subscribeTag 10000
#define unsubscribeTag 20000
#define newLabelTag 30000

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.client clearAndCancel];
    self.client = nil;
    self.feedOpertaionControllers = nil;
    self.subscription = nil;
    self.activityLabel = nil;
    [self.timer invalidate];
    self.timer = nil;
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.feedOpertaionControllers = nil;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.feedOpertaionControllers makeObjectsPerformSelector:@selector(viewDidDisappear)];
}

-(NSMutableArray*)feedOpertaionControllers{
    if (_feedOpertaionControllers== nil){
        _feedOpertaionControllers = [[NSMutableArray alloc] init];
        BRFeedDetailViewSource* detailController = [[[BRFeedDetailViewSource alloc] init] autorelease];
        detailController.subscription = self.subscription;
        detailController.tableController = self;
        BRFeedLabelsViewSource* labelsController = [[[BRFeedLabelsViewSource alloc] init] autorelease];
        labelsController.subscription = self.subscription;
        labelsController.tableController = self;
        BRFeedControlViewSource* controlsController = [[[BRFeedControlViewSource alloc] init] autorelease];
        controlsController.subscription = self.subscription;
        controlsController.tableController = self;
        BRRelatedFeedViewSource* relatedFeedController = [[[BRRelatedFeedViewSource alloc] init] autorelease];
        relatedFeedController.subscription = self.subscription;
        relatedFeedController.tableController = self;
        [_feedOpertaionControllers addObject:detailController];
        if ([GoogleReaderClient containsSubscription:self.subscription.ID] == NO){
            [_feedOpertaionControllers addObject:controlsController];        
        }
        if ([GoogleReaderClient containsSubscription:self.subscription.ID] == YES){
            [_feedOpertaionControllers addObject:labelsController];
        }
        if ([GoogleReaderClient containsSubscription:self.subscription.ID] == YES){
            [_feedOpertaionControllers addObject:controlsController];        
        }
        [_feedOpertaionControllers addObject:relatedFeedController];
    }
    
    return _feedOpertaionControllers;
}

#pragma mark - table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BRFeedConfigBase* controller = [self.feedOpertaionControllers objectAtIndex:indexPath.section];
    [controller didSelectRowAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [controller
}

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
    return [controller tableView:tableView cellForRow:indexPath.row];
}

-(void)reloadSectionFromSource:(BRFeedConfigBase*)source{
    NSInteger index = [self.feedOpertaionControllers indexOfObject:source];
    if (index != NSNotFound){
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)reloadRowsFromSource:(BRFeedConfigBase*)source row:(NSInteger)row animated:(BOOL)animated{
    NSInteger section = [self.feedOpertaionControllers indexOfObject:source];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    
    UITableViewRowAnimation animation = UITableViewRowAnimationNone;
    if(animated){
        animation = UITableViewRowAnimationAutomatic;
    }
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animation];
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

#pragma mark - table callback action
-(void)showSubscription:(GRSubscription*)subscription{
    BRFeedViewController* feedController = [[[BRFeedViewController alloc] initWithTheNibOfSameName] autorelease];
    feedController.subscription = subscription;
    [[self topContainer] replaceTopByController:feedController animated:YES];
}

-(void)showAddNewTagView{
    UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"title_pleaseinputlabelname", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"title_cancel", nil) otherButtonTitles:NSLocalizedString(@"title_ok", nil), nil] autorelease];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = newLabelTag;
    [alertView show];
}
-(void)addNewTag{
    
}
-(void)addTag:(NSString*)addID removeTag:(NSString*)removeID{
    
}
-(void)unsubscribeButtonClicked{
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"message_unsubscribe", nil), self.subscription.title] delegate:self cancelButtonTitle:NSLocalizedString(@"title_cancel", nil) otherButtonTitles:NSLocalizedString(@"title_ok", nil), nil] autorelease];
    alert.tag = unsubscribeTag;
    [alert show];
}
-(void)subscribeButtonClicked{
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"message_subscribe", nil), self.subscription.title] delegate:self cancelButtonTitle:NSLocalizedString(@"title_cancel", nil) otherButtonTitles:NSLocalizedString(@"title_ok", nil), nil] autorelease];
    alert.tag = subscribeTag;
    [alert show];
}
-(void)renameButtonClicked{
    
}

#pragma mark - alert view call back
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    self.activityLabel = [BaseActivityLabel loadFromBundle];
    if (buttonIndex == 1){        //ok button clicked
        switch (alertView.tag) {
            case subscribeTag:
            {
                //unsubscribe
                self.activityLabel.message = NSLocalizedString(@"message_subscribing", nil);
                [self.activityLabel show];
                [self startTimer];
                [self.client clearAndCancel];
                self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(subscribeDidFinish:)];
                [self.client addSubscription:self.subscription.ID withTitle:self.subscription.title toTag:nil];
            }
                break;
            case unsubscribeTag:
            {
                //subscribe
                self.activityLabel.message = NSLocalizedString(@"message_unsubscribing", nil);
                [self.activityLabel show];
                [self startTimer];
                [self.client clearAndCancel];
                self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(unsubscribeDidFinish:)];
                [self.client removeSubscription:self.subscription.ID];
            }
                break;
            case newLabelTag:
            {
                self.activityLabel.message = NSLocalizedString(@"message_addnewtag", nil);
                [self.activityLabel show];
                [self startTimer];
                NSString* string = [alertView textFieldAtIndex:0].text;
                if (string.length > 0){
                    [self.client clearAndCancel];
                    self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(addNewTagFinished:)];
                    [self.client editSubscription:self.subscription.ID tagToAdd:string tagToRemove:nil];
                }
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - google reader client callback
-(void)unsubscribeDidFinish:(GoogleReaderClient*)client{
    [self stopTimer];
    if ([client isResponseOK]){
        self.activityLabel.message = NSLocalizedString(@"message_unsubscribesucceded", nil);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FEED_UNSUBSCRIBED object:self.subscription.ID];
    }else{
        self.activityLabel.message = NSLocalizedString(@"message_unsubscribefailed", nil);
    }
    [self.activityLabel performSelector:@selector(dismiss) withObject:nil afterDelay:1.0f];
}

-(void)subscribeDidFinish:(GoogleReaderClient*)client{
    [self stopTimer];
    if ([client isResponseOK]){
        self.activityLabel.message = NSLocalizedString(@"message_subscribesucceded", nil);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FEED_SUBSCRIBED object:self.subscription.ID];
        self.feedOpertaionControllers = nil;
        [self.tableView reloadData];
    }else{
        self.activityLabel.message = NSLocalizedString(@"message_subscribefailed", nil);
    }
    [self.activityLabel performSelector:@selector(dismiss) withObject:nil afterDelay:1.0f];
}

-(void)addNewTagFinished:(GoogleReaderClient*)client{
    [self stopTimer];
    if ([client isResponseOK]){
        self.activityLabel.message = NSLocalizedString(@"message_addnewtagsucceded", nil);
        NSInteger sectionIndex;
        for (id obj in self.feedOpertaionControllers){
            if ([obj isKindOfClass:[BRFeedLabelsViewSource class]]){
                sectionIndex = [self.feedOpertaionControllers indexOfObject:obj];
                break;
            }
        }
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        self.activityLabel.message = NSLocalizedString(@"message_addnewtagfailed", nil);
    }
    [self.activityLabel performSelector:@selector(dismiss) withObject:nil afterDelay:1.0f];
}

#pragma mark - timer
-(void)startTimer{
    NSTimer* timer = [NSTimer timerWithTimeInterval:6.0f target:self selector:@selector(showUnknownError) userInfo:nil repeats:NO];
    [self.timer invalidate];
    self.timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)stopTimer{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)showUnknownError{
    self.activityLabel.message = NSLocalizedString(@"message_unknownerror", nil);
    [self.activityLabel performSelector:@selector(dismiss) withObject:nil afterDelay:1.0f];
}

@end
