//
//  BRSettingBaseController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRSettingBaseController.h"

@interface BRSettingBaseController ()

@end

@implementation BRSettingBaseController

@synthesize settingDataSources = _settingDataSources;
@synthesize tableView = _tableView;

-(void)dealloc{
    self.settingDataSources = nil;
    self.tableView = nil;
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.tableView = nil;
    self.settingDataSources = nil;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.settingDataSources makeObjectsPerformSelector:@selector(viewDidDisappear)];
}

-(NSMutableArray*)settingDataSources{
    if (_settingDataSources== nil){
        _settingDataSources = [[NSMutableArray alloc] init];
        //add data source here
    }
    
    return _settingDataSources;
}

#pragma mark - table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id<BRSettingDataSource> controller = [self.settingDataSources objectAtIndex:indexPath.section];
    if ([controller respondsToSelector:@selector(didSelectRowAtIndex:)]){
        [controller didSelectRowAtIndex:indexPath.row];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //    [controller
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id<BRSettingDataSource> controller = [self.settingDataSources objectAtIndex:indexPath.section];
    if ([controller respondsToSelector:@selector(heightOfRowAtIndex:)]){
        return [controller heightOfRowAtIndex:indexPath.row];
    }
    
    return 44.0f;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    id<BRSettingDataSource> controller = [self.settingDataSources objectAtIndex:section];
    
    if ([controller respondsToSelector:@selector(sectionTitle)]){
        return controller.sectionTitle;
    }
    return nil;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    id<BRSettingDataSource> controller = [self.settingDataSources objectAtIndex:section];
    if ([controller respondsToSelector:@selector(sectionView)]){
        return [controller sectionView];
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    id<BRSettingDataSource> controller = [self.settingDataSources objectAtIndex:section];
    if ([controller respondsToSelector:@selector(heightForHeader)]){
        return [controller heightForHeader];
    }
    
    return 20.0f;
}

#pragma mark - table view datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id<BRSettingDataSource> controller = [self.settingDataSources objectAtIndex:section];
    return [controller numberOfRowsInSection];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.settingDataSources count];
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id<BRSettingDataSource> controller = [self.settingDataSources objectAtIndex:indexPath.section];
    return [controller tableView:tableView cellForRow:indexPath.row];
}

-(void)reloadSectionFromSource:(id<BRSettingDataSource>)source{
    NSInteger index = [self.settingDataSources indexOfObject:source];
    if (index != NSNotFound){
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)reloadRowsFromSource:(id<BRSettingDataSource>)source row:(NSInteger)row animated:(BOOL)animated{
    NSInteger section = [self.settingDataSources indexOfObject:source];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    
    UITableViewRowAnimation animation = UITableViewRowAnimationNone;
    if(animated){
        animation = UITableViewRowAnimationAutomatic;
    }
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animation];
}
@end
