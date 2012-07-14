//
//  BRExplorPageViewController.m
//  BreezyReader2
//
//  Created by 津 金 on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRExplorePageViewController.h"
#import "BRExplorePageDataSource.h"

@interface BRExplorPageViewController ()

@end

@implementation BRExplorPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)createSource{
    self.source = [[[BRExplorePageDataSource alloc] init] autorelease];
    self.source.delegate = self;
}

@end
