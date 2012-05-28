//
//  BRAccountSettingCell.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRAccountSettingCell.h"
#import "JJSocialShareManager.h"

@implementation BRAccountSettingCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setCellConfig:(NSDictionary *)dictionary{
    [super setCellConfig:dictionary];
    NSString* identifier = [dictionary objectForKey:@"identifier"];
    JJSocialShareManager* manager = [JJSocialShareManager sharedManager];
    JJSocialShareService service = [manager serviceTypeForIdentifier:identifier];
    UISwitch* switcher = [[[UISwitch alloc] init] autorelease];
    switcher.on = [manager isServiceAutherized:service];
    if ([[dictionary objectForKey:@"editable"] boolValue] == NO || switcher.on == NO){
        switcher.enabled = NO;
    }
    [switcher addTarget:self action:@selector(boolValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.accessoryView = switcher;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
