//
//  BRFeedDragDownController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedDragDownController.h"

@implementation BRFeedDragDownController

@synthesize titleLabel = _titleLabel, timeLabel = _timeLabel, indicator = _indicator;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){

    }
    
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
//    [self refreshLabels];
    self.indicator.hidesWhenStopped = YES;
    [self.indicator stopAnimating];
    UIView* bottomLine = [[[UIView alloc] initWithFrame:CGRectMake(7, self.view.frame.size.height-1, self.view.frame.size.width - 14, 0.5)] autorelease];
    bottomLine.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:bottomLine];
}

-(void)dealloc{
    self.timeLabel = nil;
    self.titleLabel = nil;
    self.indicator = nil;
    [super dealloc];
}

-(void)refreshLabels:(NSDate*)date{
    NSString* timeLabelText = NSLocalizedString(@"title_lastUpdatedLabel", nil);
    self.timeLabel.text = [NSString stringWithFormat:timeLabelText, date];
    [self pullToRefresh];
}

-(void)pullToRefresh{
    self.titleLabel.text = NSLocalizedString(@"title_pulltorefresh", nil);
    [self.indicator stopAnimating];
}

-(void)readyToRefresh{
    self.titleLabel.text = NSLocalizedString(@"title_release", nil);
}

-(void)refresh{
    self.titleLabel.text = NSLocalizedString(@"title_refreshing", nil);
    [self.indicator startAnimating];
}

@end
