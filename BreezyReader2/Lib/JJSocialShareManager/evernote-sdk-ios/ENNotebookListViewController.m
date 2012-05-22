//
//  ENNotebookListViewController.m
//  SocialAuthTest
//
//  Created by 金 津 on 12-5-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "EvernoteCommonDefine.h"
#import "ENNotebookListViewController.h"
#import "EvernoteSDK.h"
#import "BaseActivityLabel.h"

@interface ENNotebookListViewController ()

@property (nonatomic, retain) NSArray* notebookList;

@end

@implementation ENNotebookListViewController

@synthesize notebookList = _notebookList;

-(void)dealloc{
    self.notebookList = nil;
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
    
    self.title = EvernoteLocalizedString(@"title_notebooklist", nil);

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    BaseActivityLabel* activityLabel = [BaseActivityLabel loadFromBundle];
    activityLabel.message = EvernoteLocalizedString(@"message_fetchnotebooklist", nil);
    [activityLabel show];
    
    EvernoteNoteStore* noteStore = [EvernoteNoteStore noteStore];
    [noteStore listNotebooksWithSuccess:^(NSArray* notebooks){
        self.notebookList = notebooks;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [activityLabel setFinished:YES];
    } failure:^(NSError* error){
        [activityLabel setFinished:NO];        
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return [self.notebookList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    EDAMNotebook* notebook = [self.notebookList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = notebook.name;
    
    if ([notebook.guid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefinedNotebookGUID]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;        
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EDAMNotebook* notebook = [self.notebookList objectAtIndex:indexPath.row];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:notebook.name forKey:kUserDefinedNotebookName];
    [defaults setObject:notebook.guid forKey:kUserDefinedNotebookGUID];
    [defaults synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
