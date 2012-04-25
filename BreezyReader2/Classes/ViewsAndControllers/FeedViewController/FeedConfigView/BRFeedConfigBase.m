//
//  BRFeedConfigBase.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedConfigBase.h"

@interface BRFeedConfigBase ()

@end

@implementation BRFeedConfigBase

@synthesize subscription = _subscription;
@synthesize tableController = _tableController;

-(void)dealloc{
    self.subscription = nil;
    self.tableController = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSString*)sectionTitle{
    return nil;
}

-(NSInteger)numberOfRowsInSection{
    return 0;
}

-(id)tableView:(UITableView*)tableView cellForRow:(NSInteger)index{
    return nil;
}

-(CGFloat)heightOfRowAtIndex:(NSInteger)index{
    return 44;
}

-(CGFloat)heightForHeader{
    return 0.0f;
}

-(void)didSelectRowAtIndex:(NSInteger)index{
    
}

-(void)setSubscription:(GRSubscription *)subscription{
    if (_subscription != subscription){
        [_subscription release];
        _subscription = [subscription retain];
        [self subscriptionChanged:_subscription];
    }
}

-(void)subscriptionChanged:(GRSubscription *)newSub{
    
}

@end
