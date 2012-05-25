//
//  MPSingleWebController.m
//  BreezyReader2
//
//  Created by  on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJSingleWebController.h"

#define SingleWebLocalizedString(key, comment) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:@"SingleWeb"]

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
        self.wantsFullScreenLayout = NO;
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
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIBarStyleDefault;
    // Do any additional setup after loading the view from its nib.
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self hideGradientBackground:self.webView];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (self.navigationItem.leftBarButtonItem == nil){
        
        UIBarButtonItem* closeItem = [[[UIBarButtonItem alloc] initWithTitle:SingleWebLocalizedString(@"title_close", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(closeAction:)] autorelease];
        self.navigationItem.leftBarButtonItem = closeItem;
    }
    
    self.backIcon = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStylePlain target:self.webView action:@selector(goBack)] autorelease];
    self.backIcon.tintColor = nil;
    self.forwardIcon = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forwardIcon"] style:UIBarButtonItemStylePlain target:self.webView action:@selector(goForward)] autorelease];
    self.forwardIcon.tintColor = nil;
    self.refreshIcon = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.webView action:@selector(reload)] autorelease];
    self.refreshIcon.tintColor = nil;
    self.stopIcon = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self.webView action:@selector(stopLoading)] autorelease];
    self.actionIcon = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionAction:)] autorelease];
    self.actionIcon.tintColor = nil;

    [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    CGRect frame = [UIScreen mainScreen].bounds;
//    frame.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
//    frame.size.height -= frame.origin.y;
//    self.view.frame = frame;
    self.navigationController.toolbarHidden = NO;
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
    UIActionSheet* sheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:SingleWebLocalizedString(@"title_cancel", nil) destructiveButtonTitle:nil otherButtonTitles:SingleWebLocalizedString(@"title_openinsafari", nil),nil] autorelease];
    [sheet showFromToolbar:self.navigationController.toolbar];
}

-(void)closeAction:(id)sender{
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
