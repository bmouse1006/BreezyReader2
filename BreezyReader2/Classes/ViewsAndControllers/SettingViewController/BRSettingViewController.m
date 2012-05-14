//
//  BRSettingViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRSettingViewController.h"
#import "UserPreferenceDefine.h"
#import "BRSettingCell.h"

@interface BRSettingViewController ()

@property (nonatomic, retain) NSArray* settingConfigs;

@end

@implementation BRSettingViewController

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
     self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_background_pattern"]];
    [UIApplication sharedApplication].statusBarStyle = UIBarStyleBlack;
    UIBarButtonItem* close = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)] autorelease];
    self.navigationItem.rightBarButtonItem = close;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)close{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - getter and setter
-(NSArray*)settingConfigs{
    if (_settingConfigs == nil){
        NSURL* url = [[NSBundle mainBundle] URLForResource:@"BRSettingConfig" withExtension:@"plist"];
        _settingConfigs = [[NSArray arrayWithContentsOfURL:url] retain];
    }
    
    return _settingConfigs;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.settingConfigs count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[self.settingConfigs objectAtIndex:section] objectForKey:@"configs"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BRSettingCell";
    BRSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[[BRSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.delegate = self;
    }
    
    [cell setCellConfig:[self objectAtIndexPath:indexPath]];
    // Configure the cell...
    
    return cell;
}

-(id)objectAtIndexPath:(NSIndexPath*)indexPath{
    return [[[self.settingConfigs objectAtIndex:indexPath.section] objectForKey:@"configs"] objectAtIndex:indexPath.row];
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* config = [self objectAtIndexPath:indexPath];
    NSString* type = [[config objectForKey:@"type"] lowercaseString];
//    NSString* identifier = [[config objectForKey:@"identifier"] lowercaseString];
    if ([type isEqualToString:@"more"]){
        NSString* next = [config objectForKey:@"next"];
        id controller = [[[NSClassFromString(next) alloc] initWithNibName:next bundle:nil] autorelease];
        if (controller){
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString* titleKey = [[self.settingConfigs objectAtIndex:section] objectForKey:@"name"];
    return NSLocalizedString(titleKey, nil);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - setting cell actions delegate
-(void)valueChangedForIdentifier:(NSString*)identifier newValue:(id)value{
    DebugLog(@"value changed for identifier: %@", identifier);
    [UserPreferenceDefine valueChangedForIdentifier:identifier value:value];
}

@end
