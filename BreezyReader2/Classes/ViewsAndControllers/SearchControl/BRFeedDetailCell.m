//
//  BRFeedDetailCell.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedDetailCell.h"
#import "NSString+Addition.h"
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
@synthesize topSeperateLine = _topSeperateLine;

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
    self.topSeperateLine = nil;
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
    [self setupCell];
}

-(void)setupCell{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (velocityForFeed == nil){
            velocityForFeed = [[NSMutableDictionary dictionary] retain];
        }
        if (subCountForFeed == nil){
            subCountForFeed = [[NSMutableDictionary dictionary] retain];
        }
    });
    
    [self.contentView addSubview:self.container];
    
    self.titleLabel.verticalAlignment = JJTextVerticalAlignmentTop;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.textColor = [UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1];
    self.titleLabel.shadowEnable = YES;
    self.titleLabel.shadowColor = [UIColor whiteColor];
    self.titleLabel.shadowOffset = CGSizeMake(0,1);
    
    CGRect frame = self.topSeperateLine.frame;
    frame.size.height = 0.5f;
    frame.size.width = self.bounds.size.width-20;
    frame.origin.x = 10;
    frame.origin.y = 0;
    [self.topSeperateLine setFrame:frame];
    
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_background_pattern"]];

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
        if (json == nil){
            return;
        }
        self.velocityLabel.text = [NSString stringWithFormat:NSLocalizedString(@"title_velocitylabel", nil), [json objectForKey:@"velocity"]];
        self.subscriberLabel.text = [NSString stringWithFormat:NSLocalizedString(@"title_subscribercount", nil), [json objectForKey:@"subscribers"]];
        [velocityForFeed setObject:[json objectForKey:@"velocity"] forKey:[self.item objectForKey:@"url"]];
        [subCountForFeed setObject:[json objectForKey:@"subscribers"] forKey:[self.item objectForKey:@"url"]];
    }
}

@end
