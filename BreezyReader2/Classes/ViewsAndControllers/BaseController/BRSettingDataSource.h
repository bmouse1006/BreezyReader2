//
//  BRSettingDataSource.h
//  BreezyReader2
//
//  Created by 金 津 on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BRSettingDataSource <NSObject>

@required
-(NSInteger)numberOfRowsInSection;
-(id)tableView:(UITableView*)tableView cellForRow:(NSInteger)index;

@optional
-(UIView*)sectionView;
-(NSString*)sectionTitle;
-(CGFloat)heightOfRowAtIndex:(NSInteger)index;
-(CGFloat)heightForHeader;

-(void)didSelectRowAtIndex:(NSInteger)index;

@end
