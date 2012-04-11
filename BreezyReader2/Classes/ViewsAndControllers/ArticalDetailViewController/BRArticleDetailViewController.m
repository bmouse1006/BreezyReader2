//
//  BRArticalDetailViewController.m
//  BreezyReader2
//
//  Created by  on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRArticleDetailViewController.h"
#import "UIViewController+addition.h"
#import "GRItem.h"
#import "NSString+MD5.h"
#import "RegexKitLite.h"

#define kPlaceHolderArticleTitle @"#BREEZYREADERARTICLETITLE#"
#define kPlaceHolderArticleContent @"#BREEZYREADERARTICLECONTENT#"
#define kPlaceHolderCSSFilePath @"#BREEZYREADERREADABILITYCSSFILEPATH#"
#define kPlaceHolderJSFilePath @"#BREEZYREADERREADABILITYFILEPATH#"

@interface BRArticleDetailViewController (){
    BOOL _formatted;
}

@end

@implementation BRArticleDetailViewController

static NSString* style = @"style-newspaper";
static NSString* size = @"size-medium";
static NSString* margin = @"margin-narrow";                   

static NSString* scriptTemplate   = @"(function(){readConvertLinksToFootnotes=false;readStyle='%@';readSize='%@';readMargin='%@';_readability_script=document.createElement('SCRIPT');_readability_script.type='text/javascript';_readability_script.src='%@';document.getElementsByTagName('head')[0].appendChild(_readability_script);_readability_css=document.createElement('LINK');_readability_css.rel='stylesheet';_readability_css.href='%@';_readability_css.type='text/css';_readability_css.media='screen';document.getElementsByTagName('head')[0].appendChild(_readability_css);})();";
                                                
@synthesize webView = _webView;
@synthesize item = _item;

-(void)dealloc{
    self.webView = nil;
    self.item = nil;
    [super dealloc];
}

-(id)initWithItem:(GRItem*)item{
    self = [super initWithTheNibOfSameName];
    if (self) {
        // Custom initialization
        self.item = item;
    }
    return self;
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
    [self removeGradientImage:self.webView];
    // Do any additional setup after loading the view from its nib.
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    CGFloat insetsTop = self.navigationController.navigationBar.frame.size.height;
    CGFloat insetsTop = 0;
    UIEdgeInsets inset = UIEdgeInsetsMake(insetsTop, 0, 0, 0);
    [self.webView.scrollView setContentInset:inset];
    [self.webView.scrollView setScrollIndicatorInsets:inset];
//    GRItem* item = [self.feed getItemAtIndex:self.index];
    DebugLog(@"item id is %@", self.item.ID);
    DebugLog(@"item title is %@", self.item.title);
    NSString* content = (self.item.content.length > 0)?self.item.content:self.item.summary;
    
    content = [self preprocessContent:(NSString*)content];
    if (content == nil){
        content = @"";
    }

    NSString* js_url = [[NSBundle mainBundle] pathForResource:@"readability" ofType:@"js"];
    NSString* css_url = [[NSBundle mainBundle] pathForResource:@"readability" ofType:@"css"];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"html"];
    NSMutableString* htmlTemplate = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    @try {
        NSRange range = {0, htmlTemplate.length};
        [htmlTemplate replaceOccurrencesOfString:kPlaceHolderArticleTitle withString:self.item.presentationString options:NSLiteralSearch range:range];
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
    
    NSString* filename = [[self.item.ID MD5] stringByAppendingPathExtension:@"html"];
    NSString* tempFile = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    [htmlTemplate writeToFile:tempFile atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:tempFile]];
    [self.webView loadRequest:request];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    NSString* filename = [[self.item.ID MD5] stringByAppendingPathExtension:@"html"];
    NSString* tempFile = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    [[NSFileManager defaultManager] removeItemAtPath:tempFile error:NULL];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - web view delegate
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    DebugLog(@"web view did finish load");
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    DebugLog(@"web view did start load");
}

-(void)scrollToTop{
    [self.webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

-(NSString*)preprocessContent:(NSString*)content{
    //remove iframe and ad
    NSString* temp = [content stringByReplacingOccurrencesOfRegex:@"<iframe\\s*.*\\s*iframe>" withString:@""];
    return [temp stringByReplacingOccurrencesOfRegex:@"<a\\s*[^>]*?feedsportal.*?/a>" withString:@""];
}

@end
