//
//  BRAccountSetting.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRAccountSetting.h"
#import "BRSettingCell.h"
#import "BRSocialAccountsSettingController.h"

@interface BRAccountSetting()

@end

@implementation BRAccountSetting

-(NSString*)sectionTitle{
    return NSLocalizedString(@"title_accounts", nil);
}

-(NSString*)configName{
    return @"BRAccountSetting";
}

-(void)valueChangedForIdentifier:(NSString*)identifier newValue:(id)value{
    [super valueChangedForIdentifier:identifier newValue:value];
}

-(void)moreCellSelectedForIdentifier:(NSString*)identifier{
    BRSocialAccountsSettingController* controller = [[[BRSocialAccountsSettingController alloc] initWithNibName:@"BRSocialAccountsSettingController" bundle:nil] autorelease];
    [self.viewController.navigationController pushViewController:controller animated:YES];
}

@end
