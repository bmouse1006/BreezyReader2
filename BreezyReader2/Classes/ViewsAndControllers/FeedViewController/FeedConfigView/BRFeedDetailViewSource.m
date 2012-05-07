//
//  BRFeedDetailViewSource.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedDetailViewSource.h"
#import "GoogleReaderClient.h"
#import "NSDate+simpleFormat.h"

@interface BRFeedDetailViewSource ()

@property (nonatomic, retain) GoogleReaderClient* client;

@end

@implementation BRFeedDetailViewSource

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

- (UITableViewCell*)loadCell
{
    if (self.container == nil){
        [[NSBundle mainBundle] loadNibNamed:@"BRFeedDetailViewSource" owner:self options:nil];
    }
    
    [self setupLabel:self.titleLabel];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.shadowEnable = YES;
    // Do any additional setup after loading the view from its nib.
    [self setupLabel:self.urlLabel];
    [self setupLabel:self.descLabel];
    [self setupLabel:self.weeklyArticleCountLabel];
    [self setupLabel:self.subscriberLabel];
    [self setupLabel:self.lastUpdateLabel];
    self.titleLabel.text = self.subscription.title;
    //start load description
    [self.client clearAndCancel];
    self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(receivedFeedDetails:)];
    [self.client getStreamDetails:self.subscription.ID];
    
    UITableViewCell* cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:self.container];
    return cell;
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

-(NSInteger)numberOfRowsInSection{
    return 1;
}

-(id)tableView:(UITableView *)tableView cellForRow:(NSInteger)index{
    return [self loadCell];
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
