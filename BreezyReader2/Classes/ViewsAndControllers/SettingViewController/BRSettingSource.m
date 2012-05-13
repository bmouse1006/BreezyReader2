//
//  BRSettingSource.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRSettingSource.h"
#import "BRSettingCell.h"
#import "UserPreferenceDefine.h"

@implementation BRSettingSource

@synthesize settingConfigs = _settingConfigs, configName = _configName;

@synthesize viewController = _viewController;

-(void)dealloc{
    self.settingConfigs = nil;
    self.configName = nil;
    [super dealloc];
}

-(NSArray*)settingConfigs{
    if (!_settingConfigs){
        NSURL* url = [[NSBundle mainBundle] URLForResource:self.configName withExtension:@"plist"];
        _settingConfigs = [[NSArray arrayWithContentsOfURL:url] retain];
    }
    
    return _settingConfigs;
}

-(id)tableView:(UITableView*)tableView cellForRow:(NSInteger)index{
    static NSString *CellIdentifier = @"settingCell";
    BRSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell){
        cell = [[[BRSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.delegate = self;
    }
    
    [cell setCellConfig:[self.settingConfigs objectAtIndex:index]];
    
    return cell;
}

-(NSInteger)numberOfRowsInSection{
    return [self.settingConfigs count];
}

-(void)didSelectRowAtIndex:(NSInteger)index{
    NSString* type = [[self.settingConfigs objectAtIndex:index] objectForKey:@"type"];
    NSString* identifier = [[self.settingConfigs objectAtIndex:index] objectForKey:@"identifier"];
    if([type isEqualToString:@"more"]){
        [self moreCellSelectedForIdentifier:identifier];
    }
}

-(void)moreCellSelectedForIdentifier:(NSString*)identifier{
    
}

-(void)valueChangedForIdentifier:(NSString *)identifier newValue:(id)value{
    [UserPreferenceDefine valueChangedForIdentifier:identifier value:value]; 
}
@end
