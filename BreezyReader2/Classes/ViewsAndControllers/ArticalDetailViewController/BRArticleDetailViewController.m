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
#import "NSString+Addition.h"
#import "RegexKitLite.h"
#import "BRImageScrollController.h"

#import "JJSingleWebController.h"

#define kPlaceHolderArticleHeader @"#BREEZYREADERARTICLEHEADER#"
#define kPlaceHolderArticleHeaderUrl @"#BREEZYREADERARTICLEHEADERURL#"
#define kPlaceHolderArticleTitle @"#BREEZYREADERARTICLETITLE#"
#define kPlaceHolderArticleContent @"#BREEZYREADERARTICLECONTENT#"
#define kPlaceHolderCSSFilePath @"#BREEZYREADERREADABILITYCSSFILEPATH#"
#define kPlaceHolderJSFilePath @"#BREEZYREADERREADABILITYFILEPATH#"

#define kPlaceHolderJQueryFilePath          @"BREEZYREADERJQUERYFILEPATH"
#define kPlaceHolderJQueryLazyLoaderFilePath  @"BREEZYREADERJQUERYLAZYLOADERPATH"

@interface BRArticleDetailViewController (){
    BOOL _formatted;
    
    BOOL _imageClicked;
}

-(NSString*)filePathForItemID:(NSString*)itemID;

@end

@implementation BRArticleDetailViewController

static NSString* style = @"style-newspaper";
static NSString* size = @"size-medium";
static NSString* margin = @"margin-narrow";                   

static NSString* scriptTemplate   = @"(function(){readConvertLinksToFootnotes=false;readStyle='%@';readSize='%@';readMargin='%@';_readability_script=document.createElement('SCRIPT');_readability_script.type='text/javascript';_readability_script.src='%@';document.getElementsByTagName('head')[0].appendChild(_readability_script);_readability_css=document.createElement('LINK');_readability_css.rel='stylesheet';_readability_css.href='%@';_readability_css.type='text/css';_readability_css.media='screen';document.getElementsByTagName('head')[0].appendChild(_readability_css);})();";
                                                
@synthesize webView = _webView;
@synthesize item = _item;
@synthesize loadingView = _loadingView;
@synthesize loadingLabel = _loadingLabel;
@synthesize delegate = _delegate;

-(void)dealloc{
    NSString* tempFile = [self filePathForItemID:self.item.ID];
    [[NSFileManager defaultManager] removeItemAtPath:tempFile error:NULL];
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
    
    self.loadingLabel.text = [self.item.title stringByReplacingHTMLTagAndTrim];
    
    self.webView.scrollView.delegate = self.delegate;
    [self removeGradientImage:self.webView];
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    singleTap.delegate = self;
    [self.webView addGestureRecognizer:singleTap];
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    CGFloat insetsTop = self.navigationController.navigationBar.frame.size.height;
    CGFloat insetsTop = 0;
    UIEdgeInsets inset = UIEdgeInsetsMake(insetsTop, 0, 0, 0);
    [self.webView.scrollView setContentInset:inset];
    [self.webView.scrollView setScrollIndicatorInsets:inset];
    NSString* content = (self.item.content.length > 0)?self.item.content:self.item.summary;
    
    content = [self preprocessContent:(NSString*)content];
    if (content == nil){
        content = @"";
    }

    NSString* js_url = [[NSBundle mainBundle] pathForResource:@"readability" ofType:@"js"];
    NSString* css_url = [[NSBundle mainBundle] pathForResource:@"readability" ofType:@"css"];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"html"];
//    NSString* jquery_url = [[NSBundle mainBundle] pathForResource:@"jquery-1.7.2" ofType:@"js"];
//    NSString* jquery_lazyloader_url = [[NSBundle mainBundle] pathForResource:@"jquery.lazyload" ofType:@"js"];
    NSMutableString* htmlTemplate = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];

    NSRange range = {0, htmlTemplate.length};
    [htmlTemplate replaceOccurrencesOfString:kPlaceHolderArticleTitle withString:self.item.presentationString options:NSLiteralSearch range:range];
    NSRange range1 = {0, htmlTemplate.length};
    [htmlTemplate replaceOccurrencesOfString:kPlaceHolderArticleContent withString:content options:NSLiteralSearch range:range1];
    NSRange range2 = {0, htmlTemplate.length};
    [htmlTemplate replaceOccurrencesOfString:kPlaceHolderCSSFilePath withString:css_url options:NSLiteralSearch range:range2];
    NSRange range3 = {0, htmlTemplate.length};
    [htmlTemplate replaceOccurrencesOfString:kPlaceHolderJSFilePath withString:js_url options:NSLiteralSearch range:range3];
    NSRange range4 = {0, htmlTemplate.length};
    [htmlTemplate replaceOccurrencesOfString:kPlaceHolderArticleHeader withString:self.item.origin_title options:NSLiteralSearch range:range4];
    NSRange range5 = {0, htmlTemplate.length};
    [htmlTemplate replaceOccurrencesOfString:kPlaceHolderArticleHeaderUrl withString:self.item.origin_htmlUrl options:NSLiteralSearch range:range5];
//    NSRange range4 = {0, htmlTemplate.length};
//    [htmlTemplate replaceOccurrencesOfString:kPlaceHolderJQueryFilePath withString:jquery_url options:NSLiteralSearch range:range4];
//    NSRange range5 = {0, htmlTemplate.length};
//    [htmlTemplate replaceOccurrencesOfString:kPlaceHolderJQueryLazyLoaderFilePath withString:jquery_lazyloader_url options:NSLiteralSearch range:range5];
    
    filePath = [self filePathForItemID:self.item.ID];
    [htmlTemplate writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]];
    [self.webView loadRequest:request];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.webView = nil;
    self.loadingView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSString*)filePathForItemID:(NSString*)itemID{
    NSString* filename = [[itemID MD5] stringByAppendingPathExtension:@"html"];
    NSString* cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
    NSString* tempFile = [cachePath stringByAppendingPathComponent:filename];
    return tempFile;
}
#pragma mark - web view delegate
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    DebugLog(@"web view did finish load");
    [self.loadingView removeFromSuperview];
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    DebugLog(@"web view did start load");
    [self.loadingView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.2];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (_imageClicked){
        _imageClicked = NO;
        return NO;
    }
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked){
        //promote a single web view;
        NSString* scheme = [[request URL].scheme lowercaseString];
        if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]){
            JJSingleWebController* singleWeb = [[JJSingleWebController alloc] init];
            singleWeb.URL = [request URL];
            UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:singleWeb];
            [UIApplication sharedApplication].statusBarHidden = NO;
            [self presentViewController:nav animated:YES completion:NULL];
        }
        
        return NO;
    }
    
    return YES;
}

-(void)scrollToTop{
    [self.webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

#pragma mark - prepare content

-(NSString*)preprocessContent:(NSString*)content{
    //remove iframe and ad
    NSString* temp = content;
//    NSString* temp = [temp stringByReplacingOccurrencesOfRegex:@"<iframe\\s*.*\\s*iframe>" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfRegex:@"<iframe\\s*[^>]*>" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfRegex:@"<[^>]*/iframe>" withString:@""];
//    temp = [temp stringByReplacingOccurrencesOfRegex:@"<font[^>]*>" withString:@"<span>"];
//    temp = [temp stringByReplacingOccurrencesOfRegex:@"<[^>]*/font>" withString:@"</span>"];
//    temp = [temp stringByReplacingOccurrencesOfRegex:@"<br[^>]*>" withString:@"<p>"];
//    temp = [temp stringByReplacingOccurrencesOfRegex:@"<[^>]*/br>" withString:@"</p>"];
    temp = [temp stringByReplacingOccurrencesOfRegex:@"<a\\s*[^>]*?feedsportal.*?/a>" withString:@""];
    return temp;
}

#pragma mark - gesture recgonizer delegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

-(void)singleTapAction:(UITapGestureRecognizer*)gesture{
    CGPoint pt = [gesture locationInView:self.webView]; 
    NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", pt.x, pt.y];
    NSString * tagName = [self.webView stringByEvaluatingJavaScriptFromString:js]; 
    if ([[tagName lowercaseString] isEqualToString:@"img"]) { 
        NSString *scriptToGetSrc = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y]; 
        NSString *imageUrl = [self.webView stringByEvaluatingJavaScriptFromString:scriptToGetSrc];
        DebugLog(@"image url=%@", imageUrl); 
        _imageClicked = YES;
        //show image scroll
        NSArray* imageList = [self.item imageURLList];
        NSInteger index = [imageList indexOfObject:imageUrl];
        BRImageScrollController* imageScroller = [[BRImageScrollController alloc] initWithTheNibOfSameName];
        [imageScroller setImageList:imageList startIndex:index];
        [[self topContainer] addToTop:imageScroller animated:YES];
    }else{
        _imageClicked = NO;
    }
}

#pragma mark - change font size
-(void)increaseFontsize{
    
}

-(void)decreaseFontsize{
    
}

@end
