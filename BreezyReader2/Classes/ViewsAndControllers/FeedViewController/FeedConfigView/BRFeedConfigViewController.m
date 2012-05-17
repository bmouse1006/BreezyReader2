//
//  BRFeedConfigViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "UIViewController+BRAddition.h"
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

@synthesize settingDataSources = _settingDataSources;

@synthesize client = _client;
@synthesize activityLabel = _activityLabel;

#define subscribeTag 10000
#define unsubscribeTag 20000
#define newLabelTag 30000

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.client clearAndCancel];
    self.client = nil;
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
        self.wantsFullScreenLayout = YES;
        [self registerNotifications];
    }
    return self;
}

-(NSMutableArray*)settingDataSources{
    if (_settingDataSources== nil){
        _settingDataSources = [[NSMutableArray alloc] init];
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
        [_settingDataSources addObject:detailController];
        if ([GoogleReaderClient containsSubscription:self.subscription.ID] == NO){
            [_settingDataSources addObject:controlsController];        
        }
        if ([GoogleReaderClient containsSubscription:self.subscription.ID] == YES){
            [_settingDataSources addObject:labelsController];
        }
        if ([GoogleReaderClient containsSubscription:self.subscription.ID] == YES){
            [_settingDataSources addObject:controlsController];        
        }
        [_settingDataSources addObject:relatedFeedController];
    }
    
    return _settingDataSources;
}

-(void)registerNotifications{
//    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
//    [nc addObserver:self selector:@selector(unsubscribeFeed:) name:NOTIFICATION_CONFIG_UNSUBSCRIBEFEED object:nil];
//    [nc addObserver:self selector:@selector(renameFeed:) name:NOTIFICATION_CONFIG_RENAMEFEED object:nil];
//    [nc addObserver:self selector:@selector(addTagToFeed:) name:NOTIFICATION_CONFIG_ADDTAG object:nil];
//    [nc addObserver:self selector:@selector(removeTagFromFeed:) name:NOTIFICATION_CONFIG_REMOVETAG object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu-background"]];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}



#pragma mark - notification callback
//-(void)unsubscribeFeed:(NSNotification*)notification{
//
//}
//
//-(void)renameFeed:(NSNotification*)notification{
//
//}
//
//-(void)addTagToFeed:(NSNotification*)notification{
//
//}
//
//-(void)removeTagFromFeed:(NSNotification*)notification{
//
//}

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
                [self subscribe];
            }
                break;
            case unsubscribeTag:
            {
                //subscribe
                [self unsubscribe];
            }
                break;
            case newLabelTag:
            {
                [self addNewTag:[alertView textFieldAtIndex:0].text];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - google reader client callback

-(void)addNewTag:(NSString*)newLabel{
    if (newLabel.length == 0){
        return;
    }
    self.activityLabel.message = NSLocalizedString(@"message_addnewtag", nil);
    [self.activityLabel show];
    [self startTimer];
    [self.client clearAndCancel];
    self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(addNewTagFinished:)];
    [self.client editSubscription:self.subscription.ID tagToAdd:newLabel tagToRemove:nil];
}
-(void)unsubscribe{
    self.activityLabel.message = NSLocalizedString(@"message_subscribing", nil);
    [self.activityLabel show];
    [self startTimer];
    [self.client clearAndCancel];
    self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(subscribeDidFinish:)];
    [self.client addSubscription:self.subscription.ID withTitle:self.subscription.title toTag:nil];
}

-(void)subscribe{
    self.activityLabel.message = NSLocalizedString(@"message_subscribing", nil);
    [self.activityLabel show];
    [self startTimer];
    [self.client clearAndCancel];
    self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(subscribeDidFinish:)];
    [self.client addSubscription:self.subscription.ID withTitle:self.subscription.title toTag:nil];
}

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
        self.settingDataSources = nil;
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
        for (id obj in self.settingDataSources){
            if ([obj isKindOfClass:[BRFeedLabelsViewSource class]]){
                sectionIndex = [self.settingDataSources indexOfObject:obj];
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
