//
//  MPSingleWebController.m
//  BreezyReader2
//
//  Created by  on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJSingleWebController.h"

@interface JJSingleWebController ()

@property (nonatomic, retain) UIBarButtonItem* backIcon;
@property (nonatomic, retain) UIBarButtonItem* forwardIcon;
@property (nonatomic, retain) UIBarButtonItem* refreshIcon;
@property (nonatomic, retain) UIBarButtonItem* stopIcon;
@property (nonatomic, retain) UIBarButtonItem* actionIcon;

-(void)updateUI;
-(void)hideGradientBackground:(UIView*)theView;

@end

@implementation JJSingleWebController

@synthesize webView = _webView;
@synthesize URL = _URL;
@synthesize backIcon = _backIcon, forwardIcon = _forwardIcon, refreshIcon = _refreshIcon, stopIcon = _stopIcon, actionIcon = _actionIcon;

-(void)dealloc{
    self.webView = nil;
    self.URL = nil;
    self.backIcon = nil;
    self.forwardIcon = nil;
    self.refreshIcon = nil;
    self.stopIcon = nil;
    self.actionIcon = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self hideGradientBackground:self.webView];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (self.navigationItem.leftBarButtonItem == nil){
        
        UIButton* button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)] autorelease];
        [button setTitle:@"close" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem* closeButton = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
        self.navigationItem.leftBarButtonItem = closeButton;
    }
    
    self.backIcon = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStylePlain target:self.webView action:@selector(goBack)] autorelease];
    self.forwardIcon = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forwardIcon"] style:UIBarButtonItemStylePlain target:self.webView action:@selector(goForward)] autorelease];
    self.refreshIcon = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.webView action:@selector(reload)] autorelease];
    self.stopIcon = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self.webView action:@selector(stopLoading)] autorelease];
    self.actionIcon = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionAction:)] autorelease];

    [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.navigationController.toolbarHidden = YES;
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

-(void)updateUI{
    self.backIcon.enabled = [self.webView canGoBack];
    self.forwardIcon.enabled = [self.webView canGoForward];
    
    UIBarButtonItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    if ([self.webView isLoading]){
        self.toolbarItems = [NSArray arrayWithObjects:self.backIcon, space, self.forwardIcon, space, self.stopIcon, space, self.actionIcon, nil];
        UIActivityIndicatorView* indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
        [indicator startAnimating];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:indicator] autorelease];
    }else{
        self.toolbarItems = [NSArray arrayWithObjects:self.backIcon, space, self.forwardIcon, space, self.refreshIcon, space, self.actionIcon, nil];
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - action
-(void)actionAction:(id)sender{
    UIActionSheet* sheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"title_cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"title_openinsafari", nil),nil] autorelease];
    [sheet showFromToolbar:self.navigationController.toolbar];
}

-(void)closeAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - web view delegate

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [self updateUI];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self updateUI];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self updateUI];
}

#pragma mark - hide gradient background
- (void)hideGradientBackground:(UIView*)theView

{
    for(UIView* subview in theView.subviews)
        
    {
        
        if([subview isKindOfClass:[UIImageView class]]){
            DebugLog(@"%@", [subview description]);
            subview.hidden = YES;
        }
        
        [self hideGradientBackground:subview];
        
    }
    
}

#pragma mark - action sheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        [[UIApplication sharedApplication] openURL:self.webView.request.URL];
    }
}
@end
