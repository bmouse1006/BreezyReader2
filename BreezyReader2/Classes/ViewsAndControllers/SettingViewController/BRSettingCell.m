//
//  BRSettingCell.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRSettingCell.h"
#import "UserPreferenceDefine.h"

@interface BRSettingCell ()

@property (nonatomic, retain) NSDictionary* config;

@end

@implementation BRSettingCell

@synthesize config = _config;
@synthesize delegate = _delegate;

-(void)dealloc{
    self.config = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews{
    [super layoutSubviews];
    

}

-(void)setCellConfig:(NSDictionary*)config{
    self.config = config;
    [self setNeedsLayout];
    
    NSString* type = [[self.config objectForKey:@"type"] lowercaseString];
    NSString* identifier = [[self.config objectForKey:@"identifier"] lowercaseString];
    
    self.textLabel.text = [self.config objectForKey:@"name"];
    
    if ([type isEqualToString:@"switch"]){
        UISwitch* switcher = [[[UISwitch alloc] init] autorelease];
        switcher.on = [UserPreferenceDefine boolValueForIdentifier:identifier];
        [switcher addTarget:self action:@selector(boolValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = switcher;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }else if ([type isEqualToString:@"more"]){
        self.accessoryView = nil;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
}

#pragma mark - action
-(void)boolValueChanged:(id)sender{
    UISwitch* switcher = (UISwitch*)sender;
    NSNumber* newValue = [NSNumber numberWithBool:switcher.on];
    
    if ([self.delegate respondsToSelector:@selector(valueChangedForIdentifier:newValue:)]){
        [self.delegate valueChangedForIdentifier:[self.config objectForKey:@"identifier"] newValue:newValue];
    }
}

@end
