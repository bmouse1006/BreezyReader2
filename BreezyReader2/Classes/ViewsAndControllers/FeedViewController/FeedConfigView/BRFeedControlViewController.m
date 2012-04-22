//
//  BRFeedControlViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedControlViewController.h"

@interface BRFeedControlViewController ()

@end

@implementation BRFeedControlViewController

@synthesize container = _container;

-(void)dealloc{
    self.container = nil;
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
    // Do any additional setup after loading the view from its nib.
    [((UITableViewCell*)self.view).contentView addSubview:self.container];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(NSInteger)numberOfRowsInSection{
    return 1;
}

-(id)cellForRow:(NSInteger)row{
    return self.view;
}

-(CGFloat)heightOfRowAtIndex:(NSInteger)index{
    return self.container.bounds.size.height;
}

#pragma mark - action methods
-(IBAction)unsubscriebButtonClicked:(id)sender{
    
}

-(IBAction)renameButtonClicked:(id)sender{

}

@end
