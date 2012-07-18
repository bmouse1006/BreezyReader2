//
//  BRTagAndSubListViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRTagAndSubListViewController.h"
#import "BRFeedConfigBaseCell.h"
#import "BRFeedConfigSectionView.h"
#import "BRFeedViewController.h"
#import "GoogleReaderClient.h"

@interface BRTagAndSubListViewController ()

@property (nonatomic, strong) NSArray* tagList;
@property (nonatomic, strong) NSDictionary* subscriptionDict;

@end

@implementation BRTagAndSubListViewController

@synthesize tableView = _tableView;
@synthesize tagList = _tagList;
@synthesize subscriptionDict = _subscriptionDict;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.wantsFullScreenLayout = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu-background"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
    // Release any retained subviews of the main view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadData];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)loadData{
    NSMutableArray* array = [NSMutableArray array];
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    
    NSMutableArray* allLabel = [NSMutableArray arrayWithArray:[GoogleReaderClient tagListWithType:BRTagTypeLabel]];
    [allLabel addObject:[GRTag tagWithNoLabel]];
    
    [allLabel enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop){
        GRTag* tag = obj;
        NSArray* subs = [GoogleReaderClient subscriptionsWithTagID:tag.ID];
        if ([subs count] > 0){
            [array addObject:tag];
            [dictionary setObject:subs forKey:tag.ID];
        }
    }];
    
    self.tagList = array;
    self.subscriptionDict = dictionary;
    
}

-(id)subscriptionAtIndexPath:(NSIndexPath*)indexPath{
    GRTag* tag = [self.tagList objectAtIndex:indexPath.section];
    return [[self.subscriptionDict objectForKey:tag.ID] objectAtIndex:indexPath.row];
}

#pragma mark - table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    GRSubscription* sub = [self subscriptionAtIndexPath:indexPath];
    
    BRFeedViewController* feedViewController = [[BRFeedViewController alloc] initWithTheNibOfSameName];
    
    feedViewController.subscription = sub;
    
    [[self topContainer] boomOutViewController:feedViewController fromView:cell];
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    GRTag* tag = [self.tagList objectAtIndex:section];
    BRFeedConfigSectionView* sectionView = [[BRFeedConfigSectionView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30.0f)];
    sectionView.titleLabel.text = tag.label;
    
    return sectionView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 28.0f;
}

#pragma mark - table view datasource
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GRSubscription* sub = [self subscriptionAtIndexPath:indexPath];
    static NSString* identifier = @"BRFeedConfigBaseCell";
    BRFeedConfigBaseCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        cell = [[BRFeedConfigBaseCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = sub.title;
    
    NSInteger unreadCount = [GoogleReaderClient unreadCountWithID:sub.ID];
    if (unreadCount){
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", unreadCount];
    }else{
        cell.detailTextLabel.text = nil;
    }

    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.tagList count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    GRTag* tag = [self.tagList objectAtIndex:section];
    return [[self.subscriptionDict objectForKey:tag.ID] count];
}

@end
