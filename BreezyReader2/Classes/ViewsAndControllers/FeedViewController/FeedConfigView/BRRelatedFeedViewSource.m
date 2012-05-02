//
//  BRRelatedFeedViewSource.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRRelatedFeedViewSource.h"
#import "GoogleReaderClient.h"
#import "BRRelatedFeedCell.h"
#import "BRFeedConfigViewController.h"

@interface BRRelatedFeedViewSource ()

@property (nonatomic, retain) NSMutableArray* relatedSubs;
@property (nonatomic, retain) GoogleReaderClient* client;

@end

@implementation BRRelatedFeedViewSource

@synthesize relatedSubs = _relatedSubs;
@synthesize client = _client;
@synthesize activity = _activity;
@synthesize sectionView = _sectionView;
@synthesize showButton = _showButton;

-(id)init{
    self = [super init];
    if (self){
        self.relatedSubs = [NSMutableArray array];
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        self.sectionView.titleLabel.text = NSLocalizedString(@"title_relatedfeed", nil);
        [self.activity stopAnimating];
    }
    
    return self;
}

-(void)dealloc{
    self.relatedSubs = nil;
    self.client = nil;
    self.activity = nil;
    self.showButton = nil;
    [super dealloc];
}

-(UIView*)sectionView{
    return _sectionView;
}

-(CGFloat)heightForHeader{
    return self.sectionView.bounds.size.height;
}

-(NSInteger)numberOfRowsInSection{
    return [self.relatedSubs count];
}

-(id)tableView:(UITableView*)tableView cellForRow:(NSInteger)index{
    BRRelatedFeedCell* cell = [tableView dequeueReusableCellWithIdentifier:@"BRRelatedFeedCell"];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BRRelatedFeedCell" owner:nil options:nil] objectAtIndex:0];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    GRSubscription* sub = [self.relatedSubs objectAtIndex:index];
    cell.textLabel.text = sub.title;
    
    return cell;
    
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
        
        [self.tableController reloadSectionFromSource:self];
    }else{
        self.showButton.hidden = NO;
    }
}

-(void)didSelectRowAtIndex:(NSInteger)index{
    GRSubscription* sub = [self.relatedSubs objectAtIndex:index];
    if([GoogleReaderClient containsSubscription:sub.ID]){
        sub = [GoogleReaderClient subscriptionWithID:sub.ID];
    }
    [self.tableController showSubscription:sub];
}

-(IBAction)showButtonClicked:(id)sender{
    self.showButton.hidden = YES;
    [self.activity startAnimating];
    [self.client clearAndCancel];
    self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(didReceivedRelatedSubscriptions:)];
    [self.client requestRelatedSubscriptions:self.subscription.ID];
}

@end
