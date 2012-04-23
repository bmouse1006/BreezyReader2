//
//  BRFeedDetailViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedDetailViewController.h"
#import "GoogleReaderClient.h"
#import "NSDate+simpleFormat.h"

@interface BRFeedDetailViewController ()

@property (nonatomic, retain) GoogleReaderClient* client;

@end

@implementation BRFeedDetailViewController

@synthesize titleLabel = _titleLabel, urlLabel = _urlLabel, descLabel = _descLabel, weeklyArticleCountLabel = _weeklyArticleCountLabel, subscriberLabel = _subscriberLabel, lastUpdateLabel = _lastUpdateLabel;
@synthesize container = _container;

@synthesize client = _client;

-(void)dealloc{
    self.titleLabel = nil;
    self.urlLabel = nil;
    self.descLabel = nil;
    self.weeklyArticleCountLabel = nil;
    self.subscriberLabel = nil;
    self.lastUpdateLabel = nil;
    self.container = nil;
    [self.client clearAndCancel];
    self.client = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupLabel:self.titleLabel];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.titleLabel.shadowEnable = YES;
    // Do any additional setup after loading the view from its nib.
    [self setupLabel:self.urlLabel];
    [self setupLabel:self.descLabel];
    [self setupLabel:self.weeklyArticleCountLabel];
    [self setupLabel:self.subscriberLabel];
    [self setupLabel:self.lastUpdateLabel];
    
    //start load description
    [self.client clearAndCancel];
    self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(receivedFeedDetails:)];
    [self.client getStreamDetails:self.subscription.ID];
    
    [self.view addSubview:self.container];
}

-(void)setupLabel:(JJLabel*)label{
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.verticalAlignment = JJTextVerticalAlignmentMiddle;
    label.shadowBlur = 3;
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(1, 1);
    label.shadowEnable = NO;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.titleLabel.text = self.subscription.title;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.titleLabel = nil;
    self.container = nil;
    self.urlLabel = nil;
    self.descLabel = nil;
    self.weeklyArticleCountLabel = nil;
    self.lastUpdateLabel = nil;
    self.subscriberLabel = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(NSInteger)numberOfRowsInSection{
    return 1;
}

-(id)cellForRow:(NSInteger)row{
    return self.view;
}

-(CGFloat)heightOfRowAtIndex:(NSInteger)index{
    return 135.0f;
}

#pragma mark - google reader client call back
-(void)receivedFeedDetails:(GoogleReaderClient*)client{
    if (client.error){
        NSLog(@"error message is %@", [client.error localizedDescription]);
    }else{
        DebugLog(@"%@", client.responseString);
        NSDictionary* json = client.responseJSONValue;
        self.weeklyArticleCountLabel.text = [json objectForKey:@"velocity"];
        self.subscriberLabel.text = [json objectForKey:@"subscribers"];
        self.lastUpdateLabel.text = [[NSDate dateWithTimeIntervalSince1970:[[json objectForKey:@"successfulCrawlTimeUsec"] longLongValue]/1000000] shortString];
        self.urlLabel.text = [json objectForKey:@"feedUrl"];
    }
}

/*
 sample:
 {"subscribers":"397,396","velocity":"1,130.5","successfulCrawlTimeUsec":"1335085608051405","failedCrawlTimeUsec":"1335021940628430","lastFailureWasParseFailure":false,"trendsCharts":{},"feedUrl":"http://www.cnbeta.com/backend.php"}
 */


@end
