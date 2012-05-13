//
//  BRAppearenceSetting.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRAppearenceSetting.h"

@implementation BRAppearenceSetting

@synthesize viewController = _viewController;

-(NSString*)sectionTitle{
    return NSLocalizedString(@"title_appearence", nil);
}

-(NSString*)configName{
    return @"BRAppearenceSetting";
}

-(void)didSelectRowAtIndex:(NSInteger)index{
    NSString* identifier = [[self.settingConfigs objectAtIndex:index] objectForKey:@"identifier"];
    
    if([identifier isEqualToString:@"google"]){
        
    }else if ([identifier isEqualToString:@"socialaccounts"]){
 
    }
}

-(void)valueChangedForIdentifier:(NSString*)identifier newValue:(id)value{
    [super valueChangedForIdentifier:identifier newValue:value];
}

@end
