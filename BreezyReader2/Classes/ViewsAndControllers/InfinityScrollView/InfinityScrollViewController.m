//
//  InfinityScrollViewController.m
//  BreezyReader2
//
//  Created by 金 津 on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "InfinityScrollViewController.h"
#import "TestView.h"

@implementation InfinityScrollViewController

@synthesize scrollView = _scrollView;
@synthesize contentControllers = _contentControllers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(NSInteger)numberOfContentViewsInScrollView:(InfinityScrollView*)scrollView{
    return 8;
}

-(UIView*)scrollView:(InfinityScrollView *)scrollView contentViewAtIndex:(NSInteger)index{
    TestView* view = [[[NSBundle mainBundle] loadNibNamed:@"TestView" owner:nil options:nil] objectAtIndex:0];
    view.label.text = [NSString stringWithFormat:@"%d", index];
    return view;
}

-(void)reload{
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView reloadData];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
