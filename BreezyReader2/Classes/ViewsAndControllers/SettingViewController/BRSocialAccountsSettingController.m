//
//  BRSocialAccountsSettingController.m
//  BreezyReader2
//
//  Created by Jin Jin on 12-5-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRSocialAccountsSettingController.h"
#import "BRAccountSettingCell.h"
#import "UserPreferenceDefine.h"
#import "JJSocialShareManager.h"
#import "BRUserVerifyController.h"
#import "GoogleReaderClient.h"

@interface BRSocialAccountsSettingController ()
@end

@implementation BRSocialAccountsSettingController

-(NSString*)settingFilename{
    return @"SocialAccountsSetting";
}

#pragma mark - Table view data source

-(void)viewDidLoad{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"title_accountsetting", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"accoiuntSettingCell";
    BRAccountSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell){
        cell = [[BRAccountSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
    }
    
    [cell setCellConfig:[self objectAtIndexPath:indexPath]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* config = [self objectAtIndexPath:indexPath];
    NSString* type = [[config objectForKey:@"type"] lowercaseString];
    if ([type isEqualToString:@"more"]){
        
    }
}

#pragma mark - cell actions
-(void)valueChangedForIdentifier:(NSString *)identifier newValue:(id)value{
//    [UserPreferenceDefine valueChangedForIdentifier:identifier value:value];
    JJSocialShareManager* manager = [JJSocialShareManager sharedManager];
    JJSocialShareService service = [manager serviceTypeForIdentifier:identifier];
    
    BOOL accountEnabled = [value boolValue];

    if (accountEnabled == NO){
        //log out account
        [manager logoutService:service];
    }else{
        //log on account
    }
    
    if (service == JJSocialShareServiceGoogle){
        [self dismissViewControllerAnimated:YES completion:^{
            [GoogleReaderClient removeStoredReaderData];
            BRUserVerifyController* verifyController = [[BRUserVerifyController alloc] init];
            [[[UIApplication sharedApplication].keyWindow.rootViewController topContainer] addToTop:verifyController animated:YES];
        }];
    }
}

@end
