//
//  BRSettingViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRSettingViewController.h"
#import "BRAccountSetting.h"
#import "BRAppearenceSetting.h"

@interface BRSettingViewController ()

@end

@implementation BRSettingViewController

@synthesize settingDataSources = _settingDataSources;

-(void)dealloc{
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(NSMutableArray*)settingDataSources{
    if (_settingDataSources == nil){
        _settingDataSources = [[NSMutableArray alloc] init];   
        
        BRAccountSetting* accountSetting = [[[BRAccountSetting alloc] init] autorelease];
        BRAppearenceSetting* appearenceSetting = [[[BRAppearenceSetting alloc] init] autorelease];
        
        [_settingDataSources addObject:accountSetting];
        [_settingDataSources addObject:appearenceSetting];
    }
    
    return _settingDataSources;
}


@end
