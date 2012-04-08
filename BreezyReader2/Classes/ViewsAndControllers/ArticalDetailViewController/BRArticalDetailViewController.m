//
//  BRArticalDetailViewController.m
//  BreezyReader2
//
//  Created by  on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRArticalDetailViewController.h"
#import "UIViewController+addition.h"
#import "GRItem.h"

#define kPlaceHolderArticleTitle @"#BREEZYREADERARTICLETITLE#"
#define kPlaceHolderArticleContent @"#BREEZYREADERARTICLECONTENT#"
#define kPlaceHolderCSSFilePath @"#BREEZYREADERREADABILITYCSSFILEPATH#"
#define kPlaceHolderJSFilePath @"#BREEZYREADERREADABILITYFILEPATH#"

@interface BRArticalDetailViewController (){
    BOOL _formatted;
}

@end

@implementation BRArticalDetailViewController

static NSString* style = @"style-newspaper";
static NSString* size = @"size-medium";
static NSString* margin = @"margin-narrow";                   

static NSString* scriptTemplate   = @"(function(){readConvertLinksToFootnotes=false;readStyle='%@';readSize='%@';readMargin='%@';_readability_script=document.createElement('SCRIPT');_readability_script.type='text/javascript';_readability_script.src='%@';document.getElementsByTagName('head')[0].appendChild(_readability_script);_readability_css=document.createElement('LINK');_readability_css.rel='stylesheet';_readability_css.href='%@';_readability_css.type='text/css';_readability_css.media='screen';document.getElementsByTagName('head')[0].appendChild(_readability_css);})();";
                                                
@synthesize webView = _webView;
@synthesize index = _index;
@synthesize feed = _feed;
@synthesize backButton = _backButton;
@synthesize bottomToolBar = _bottomToolBar;

-(void)dealloc{
    self.webView = nil;
    self.feed = nil;
    self.backButton = nil;
    self.bottomToolBar = nil;
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
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.backButton] autorelease];
    [self removeGradientImage:self.webView];
    // Do any additional setup after loading the view from its nib.
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    CGFloat insetsTop = self.navigationController.navigationBar.frame.size.height;
    CGFloat insetsTop = 0;
    UIEdgeInsets inset = UIEdgeInsetsMake(insetsTop, 0, 0, 0);
    [self.webView.scrollView setContentInset:inset];
    [self.webView.scrollView setScrollIndicatorInsets:inset];
    GRItem* item = [self.feed getItemAtIndex:self.index];
    NSString* content = (item.content.length > 0)?item.content:item.summary;
    if (content == nil){
        content = @"";
    }

    NSString* js_url = [[NSBundle mainBundle] pathForResource:@"readability" ofType:@"js"];
    NSString* css_url = [[NSBundle mainBundle] pathForResource:@"readability" ofType:@"css"];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"html"];
    NSMutableString* htmlTemplate = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    @try {
        NSRange range = {0, htmlTemplate.length};
        [htmlTemplate replaceOccurrencesOfString:kPlaceHolderArticleTitle withString:item.presentationString options:NSLiteralSearch range:range];
        NSRange range1 = {0, htmlTemplate.length};
        [htmlTemplate replaceOccurrencesOfString:kPlaceHolderArticleContent withString:content options:NSLiteralSearch range:range1];
        NSRange range2 = {0, htmlTemplate.length};
        [htmlTemplate replaceOccurrencesOfString:kPlaceHolderCSSFilePath withString:css_url options:NSLiteralSearch range:range2];
        NSRange range3 = {0, htmlTemplate.length};
        [htmlTemplate replaceOccurrencesOfString:kPlaceHolderJSFilePath withString:js_url options:NSLiteralSearch range:range3];
    }
    @catch (NSException *exception) {
        DebugLog(@"exception is %@", exception.reason);
    }

    
    NSString* tempFile = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.html"];
    [htmlTemplate writeToFile:tempFile atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:tempFile]];
    [self.webView loadRequest:request];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [UIApplication sharedApplication].statusBarHidden = YES;
}

//-(void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    self.navigationController.navigationBarHidden = NO;
//    [UIApplication sharedApplication].statusBarHidden = NO;
//}

-(void)viewWillLayoutSubviews{
    CGRect frame = self.bottomToolBar.frame;
    frame.origin.y = self.view.frame.size.height - frame.size.height;
    self.bottomToolBar.frame = frame;
    
    frame = self.webView.frame;
    frame.size.height = self.view.frame.size.height - self.bottomToolBar.frame.size.height;
    self.webView.frame = frame;
    
    [self.view bringSubviewToFront:self.bottomToolBar];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - web view delegate
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    DebugLog(@"web view did finish load");
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    DebugLog(@"web view did start load");
}

#pragma mark - action
-(IBAction)back:(id)sender{
    //    [self.navigationController popViewControllerAnimated:YES];
//    [[self topContainer] boomInTopViewController];
    [[self topContainer] slideOutViewController];
}

-(IBAction)scrollToTop:(id)sender{
    [self.webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

-(IBAction)viewInSafari:(id)sender{
    GRItem* item = [self.feed getItemAtIndex:self.index];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:item.origin_htmlUrl]];
}

@end
