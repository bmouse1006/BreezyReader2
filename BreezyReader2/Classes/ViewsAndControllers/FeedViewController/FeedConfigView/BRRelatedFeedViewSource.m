//
//  BRRelatedFeedViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRRelatedFeedViewController.h"
#import "GoogleReaderClient.h"

@interface BRRelatedFeedViewController ()

@property (nonatomic, retain) NSMutableArray* relatedSubs;
@property (nonatomic, retain) GoogleReaderClient* client;

@end

@implementation BRRelatedFeedViewController

@synthesize relatedSubs = _relatedSubs;
@synthesize client = _client;
@synthesize activity = _activity;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.relatedSubs = [NSMutableArray array];
    }
    
    return self;
}

-(void)dealloc{
    self.relatedSubs = nil;
    self.client = nil;
    self.activity = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.client clearAndCancel];
    self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(didReceivedRelatedSubscriptions:)];
    [self.client requestRelatedSubscriptions:self.subscription.ID];
    // Do any additional setup after loading the view from its nib
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.titleLabel.text = NSLocalizedString(@"title_relatedfeed", nil);
}

-(UIView*)sectionView{
    return self.view;
}

-(CGFloat)heightForHeader{
    return self.view.bounds.size.height;
}

-(NSInteger)numberOfRowsInSection{
    return [self.relatedSubs count];
}

-(id)cellForRow:(NSInteger)row{
    return nil;
}

-(void)didReceivedRelatedSubscriptions:(GoogleReaderClient*)client{
    [self.activity stopAnimating];
    if (client.error == nil){
        DebugLog(@"%@", client.responseString);
        NSArray* recs = [[client responseJSONValue] objectForKey:@"recs"];
        [self.relatedSubs removeAllObjects];
        for (NSDictionary* rec in recs){
            GRRecFeed* recFeed = [GRRecFeed recFeedsWithJSONObject:rec];
            GRSubscription* sub = [GRSubscription subscriptionForGRRecFeed:recFeed];
            [self.relatedSubs addObject:sub];
        }
    }
}

@end
