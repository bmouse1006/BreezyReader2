//
//  BRAccountSetting.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRAccountSetting.h"
#import "BRSocialAccountsSettingController.h"

@implementation BRAccountSetting

@synthesize viewController = _viewController;

-(NSInteger)numberOfRowsInSection{
    return 2;
}

-(id)tableView:(UITableView*)tableView cellForRow:(NSInteger)index{
    return [[[UITableViewCell alloc] init] autorelease];
}

-(NSString*)sectionTitle{
    return NSLocalizedString(@"title_accounts", nil);
}

-(void)didSelectRowAtIndex:(NSInteger)index{
    switch(index){
        case 0:
            break;
        case 1:
        {
            BRSocialAccountsSettingController* controller = [[[BRSocialAccountsSettingController alloc] initWithNibName:@"BRSocialAccountsSettingController" bundle:nil] autorelease];
            [self.viewController.navigationController pushViewController:controller animated:YES];
        }
            break;
        default:
            break;
    }
}
@end
