//
//  BRSocialAccountsSettingController.m
//  BreezyReader2
//
//  Created by Jin Jin on 12-5-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRSocialAccountsSettingController.h"
#import "BRSettingCell.h"
#import "UserPreferenceDefine.h"

@interface BRSocialAccountsSettingController ()

@property (nonatomic, retain) NSArray* settingConfigs;

@end

@implementation BRSocialAccountsSettingController

@synthesize settingConfigs = _settingConfigs;

-(void)dealloc{
    self.settingConfigs = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSArray*)settingConfigs{
    if (!_settingConfigs){
        NSURL* url = [[NSBundle mainBundle] URLForResource:@"SocialAccountsSetting" withExtension:@"plist"];
        _settingConfigs = [[NSArray arrayWithContentsOfURL:url] retain];
    }
    
    return _settingConfigs;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.settingConfigs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"settingCell";
    BRSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell){
        cell = [[[BRSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.delegate = self;
    }
    
    [cell setCellConfig:[self.settingConfigs objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* config = [self.settingConfigs objectAtIndex:indexPath.row];
    NSString* type = [[config objectForKey:@"type"] lowercaseString];
    if ([type isEqualToString:@"more"]){
        
    }
}

#pragma mark - cell actions
-(void)valueChangedForIdentifier:(NSString *)identifier newValue:(id)value{
//    [UserPreferenceDefine valueChangedForIdentifier:identifier value:value];
    BOOL accountEnabled = [value boolValue];
    
    if (accountEnabled == NO){
        //log out account
    }else{
        //log on account
    }
}

@end
