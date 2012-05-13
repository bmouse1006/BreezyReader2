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
#import "BRCacheSetting.h"

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
    UIBarButtonItem* item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close)] autorelease];
    self.navigationItem.rightBarButtonItem = item;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_background_pattern"]];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIBarStyleBlack;
}

-(void)close{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(NSMutableArray*)settingDataSources{
    if (_settingDataSources == nil){
        _settingDataSources = [[NSMutableArray alloc] init];   
        
        BRAccountSetting* accountSetting = [[[BRAccountSetting alloc] init] autorelease];
        BRAppearenceSetting* appearenceSetting = [[[BRAppearenceSetting alloc] init] autorelease];
        BRCacheSetting* cacheSetting = [[[BRCacheSetting alloc] init] autorelease];
        
        accountSetting.viewController = self;
        appearenceSetting.viewController = self;
        cacheSetting.viewController = self;
        
        [_settingDataSources addObject:accountSetting];
        [_settingDataSources addObject:appearenceSetting];
        [_settingDataSources addObject:cacheSetting];
    }
    
    return _settingDataSources;
}


@end
