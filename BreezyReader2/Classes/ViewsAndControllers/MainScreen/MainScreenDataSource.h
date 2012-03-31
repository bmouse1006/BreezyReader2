//
//  MainScreenDataSource.h
//  BreezyReader2
//
//  Created by 金 津 on 12-2-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InfinityScrollView.h"

@interface MainScreenDataSource : NSObject <InfinityScrollViewDataSource>

@property (nonatomic, retain) NSMutableArray* controllers;

-(void)reloadController;
-(void)didReceiveMemoryWarning;
-(void)superViewDidUnload;

@end
