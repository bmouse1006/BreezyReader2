//
//  BRFeedLoadMoreController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedLoadMoreController.h"

@interface BRFeedLoadMoreController ()

@end

@implementation BRFeedLoadMoreController

@synthesize titleLabel = _titleLabel, indicator = _indicator;

-(void)dealloc{
    self.titleLabel = nil;
    self.indicator = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.titleLabel.text = NSLocalizedString(@"title_loadmore", nil);
    [self.indicator stopAnimating];
}

-(void)loadMore{
    [self.indicator startAnimating];
    self.titleLabel.hidden = YES;
}

-(void)stopLoadingWithMore:(BOOL)more{
    self.titleLabel.hidden = NO;
    [self.indicator stopAnimating];
    if (more == NO){
        self.titleLabel.text = NSLocalizedString(@"title_nomore", nil);
    }else{
        self.titleLabel.text = NSLocalizedString(@"title_loadmore", nil);
    }
}

@end
