//
//  BRFeedDetailCell.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedDetailCell.h"
#import "NSString+Addtion.h"
#import "GoogleReaderClient.h"

@interface BRFeedDetailCell (){
}

@property (nonatomic, retain) GoogleReaderClient* client;
@property (nonatomic, retain) id item;

@end

@implementation BRFeedDetailCell

@synthesize container = _container;
@synthesize titleLabel = _titleLabel, snipetLabel = _snipetLabel, subscriberLabel = _subscriberLabel, velocityLabel = _velocityLabel;
@synthesize client = _client;
@synthesize item = _item;

static NSMutableDictionary* velocityForFeed = nil;
static NSMutableDictionary* subCountForFeed = nil;

-(void)dealloc{
    [self.client clearAndCancel];
    [_item release];
    _item = nil;
    self.client = nil;
    self.container = nil;
    self.titleLabel = nil;
    self.snipetLabel = nil;
    self.subscriberLabel = nil;
    self.velocityLabel = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self.contentView addSubview:self.container];
    if (velocityForFeed == nil){
        velocityForFeed = [[NSMutableDictionary dictionary] retain];
    }
    
    if (subCountForFeed == nil){
        subCountForFeed = [[NSMutableDictionary dictionary] retain];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setItem:(id)item{
    if (_item != item){
        
        [_item release];
        _item = [item retain];
        
        self.titleLabel.text = [[item objectForKey:@"title"] stringByReplacingHTMLTagAndTrim];
        self.snipetLabel.text = [[item objectForKey:@"contentSnippet"] stringByReplacingHTMLTagAndTrim];
        
        self.velocityLabel.text = [NSString stringWithFormat:NSLocalizedString(@"title_velocitylabel", nil), @""];
        self.subscriberLabel.text = [NSString stringWithFormat:NSLocalizedString(@"title_subscribercount", nil), @""];
        
        [self.client clearAndCancel];
        self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(receivedStreamDetail:)];
        
        NSString* velocity = [velocityForFeed objectForKey:[item objectForKey:@"url"]];
        NSString* subCount = [subCountForFeed objectForKey:[item objectForKey:@"url"]];
        if ([velocityForFeed objectForKey:[item objectForKey:@"url"]]){
            self.velocityLabel.text = [NSString stringWithFormat:NSLocalizedString(@"title_velocitylabel", nil), velocity];
            self.subscriberLabel.text = [NSString stringWithFormat:NSLocalizedString(@"title_subscribercount", nil), subCount];
        }else {
            [self.client getStreamDetails:[@"feed/" stringByAppendingString:[item objectForKey:@"url"]]];
        }
    }
}

-(void)receivedStreamDetail:(GoogleReaderClient*)client{
    if (client.error){
        NSLog(@"error message is %@", [client.error localizedDescription]);
    }else{
        DebugLog(@"%@", client.responseString);
        NSDictionary* json = client.responseJSONValue;
        self.velocityLabel.text = [NSString stringWithFormat:NSLocalizedString(@"title_velocitylabel", nil), [json objectForKey:@"velocity"]];
        self.subscriberLabel.text = [NSString stringWithFormat:NSLocalizedString(@"title_subscribercount", nil), [json objectForKey:@"subscribers"]];
        [velocityForFeed setObject:[json objectForKey:@"velocity"] forKey:[self.item objectForKey:@"url"]];
        [subCountForFeed setObject:[json objectForKey:@"subscribers"] forKey:[self.item objectForKey:@"url"]];
    }
}

@end
