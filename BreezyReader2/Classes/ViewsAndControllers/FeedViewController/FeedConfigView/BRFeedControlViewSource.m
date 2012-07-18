//
//  BRFeedControlViewSource.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "GoogleReaderClient.h"
#import "BRFeedControlViewSource.h"
#import "BRFeedConfigBaseCell.h"
#import "BRFeedConfigViewController.h"
#import "BRFeedConfigBaseCell.h"

@interface BRFeedControlViewSource ()

@end

@implementation BRFeedControlViewSource

@synthesize sectionView = _sectionView;
@synthesize container = _container;
@synthesize greenButton = _greenButton, redButton = _redButton;


- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self setupViews];
    }
    return self;
}

-(void)setupViews{
    self.sectionView.titleLabel.text = NSLocalizedString(@"title_feedoperation", nil);
    [self.redButton setTitle:NSLocalizedString(@"title_unsubscribe", nil) forState:UIControlStateNormal];
    self.redButton.frame = self.container.bounds;
    [self.greenButton setTitle:NSLocalizedString(@"title_subscribe", nil) forState:UIControlStateNormal];
    self.greenButton.frame = self.container.bounds;
}

-(UIView*)sectionView{
    return _sectionView;
}

-(CGFloat)heightForHeader{
    return self.sectionView.bounds.size.height;
}

-(NSInteger)numberOfRowsInSection{
    return 1;
}

-(CGFloat)heightOfRowAtIndex:(NSInteger)index{
    return self.container.bounds.size.height;
}

-(id)tableView:(UITableView*)tableView cellForRow:(NSInteger)index{
//    return self.view;
    BRFeedConfigBaseCell* cell = [[BRFeedConfigBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell.contentView addSubview:self.container];
    return cell;
}

-(void)subscriptionChanged:(GRSubscription *)newSub{
    if ([GoogleReaderClient containsSubscription:newSub.ID]){
        [self.container addSubview:self.redButton];
    }else{
        [self.container addSubview:self.greenButton];
    }
}

#pragma mark - action methods
-(IBAction)unsubscriebButtonClicked:(id)sender{
    [self.tableController unsubscribeButtonClicked];
}

-(IBAction)renameButtonClicked:(id)sender{
    
}

-(IBAction)subscribeButtonClicked:(id)sender{
    [self.tableController subscribeButtonClicked];
}

@end
