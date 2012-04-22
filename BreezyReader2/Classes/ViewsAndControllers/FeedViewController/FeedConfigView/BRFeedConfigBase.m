//
//  BRFeedConfigBase.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedConfigBase.h"

@interface BRFeedConfigBase ()

@end

@implementation BRFeedConfigBase

@synthesize subscription = _subscription;

-(void)dealloc{
    self.subscription = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(NSString*)sectionTitle{
    return nil;
}

-(UIView*)sectionView{
    return nil;
}

-(NSInteger)numberOfRowsInSection{
    return 0;
}

-(id)cellForRow:(NSInteger)row{
    return nil;
}

-(CGFloat)heightOfRowAtIndex:(NSInteger)index{
    return 44;
}

-(CGFloat)heightForHeader{
    return 0.0f;
}

@end
