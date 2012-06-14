//
//  BRManuallyClearCacheView.m
//  BreezyReader2
//
//  Created by Jin Jin on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRManuallyClearCacheView.h"
#import "BRCacheCleaner.h"
#import "BaseActivityLabel.h"

@implementation BRManuallyClearCacheView

@synthesize button = _button;

-(void)dealloc{
    self.button = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self.button setTitle:NSLocalizedString(@"title_manuallyclearcache", nil) forState:UIControlStateNormal];
}


-(IBAction)clearCache:(id)sender{
    BaseActivityLabel* activity = [BaseActivityLabel loadFromBundle];
    activity.message = NSLocalizedString(@"message_clearcache", nil);
    [activity show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[BRCacheCleaner sharedCleaner] clearHTTPResponseCacheBeforeDate:[NSDate date]];
        dispatch_async(dispatch_get_main_queue(), ^{
            activity.message = NSLocalizedString(@"title_done", nil);
            [activity setFinished:YES];    
        });
    });
}


@end
