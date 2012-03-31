//
//  CustomOAuth2ViewController.m
//  BreezyReader2
//
//  Created by  on 12-1-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CustomOAuth2ViewController.h"
#import "UIViewController+addition.h"

@interface CustomOAuth2ViewController () 

-(void)registerNotifications;
-(void)unregisterNotifications;

@end

@implementation CustomOAuth2ViewController

@synthesize backItem = _backItem;
@synthesize forwardItem = _forwardItem;
@synthesize refreshItem = _refreshItem;

@synthesize clostItem = _clostItem;

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

-(void)dealloc{
    self.backItem = nil;
    self.forwardItem = nil;
    self.refreshItem = nil;
    self.clostItem = nil;
    [self unregisterNotifications];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.clostItem] autorelease];
    [self removeGradientImage:self.webView];
    [self registerNotifications];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self unregisterNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

+ (NSString *)authNibName {
    // subclasses may override this to specify a custom nib name
    return @"CustomOAuth2ViewController";
}

-(void)registerNotifications{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ddd) name:kGTMOAuth2WebViewStartedLoading object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ddd) name:kGTMOAuth2WebViewStoppedLoading object:nil];
}

-(void)unregisterNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)updateUI{
//    [super updateUI];
    self.forwardItem.enabled = [self.webView canGoForward];
    self.backItem.enabled = [self.webView canGoBack];
}

-(IBAction)dismissSelf:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:<#(BOOL)#> completion:<#^(void)completion#>
}

@end
