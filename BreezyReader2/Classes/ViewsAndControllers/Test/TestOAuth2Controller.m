//
//  TestOAuth2Controller.m
//  BreezyReader2
//
//  Created by 金 津 on 12-1-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TestOAuth2Controller.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "CustomOAuth2ViewController.h"
#import "GTMHTTPFetcher.h"

#define kKeychainItemName   @"BreezyReader2AuthKeyChainKey"
#define kOAuth2ClientID     @"976194106514.apps.googleusercontent.com"
#define kOAuth2ClientSecret @"66XPmD_hWWI6J4LqwcCS46_H"
#define kOAuth2RedirectURI  @"urn:ietf:wg:oauth:2.0:oob"
#define kOAuthScope          @"https://www.google.com/reader/atom https://www.google.com/reader/api/"

#define kGoogleReaderList   @"https://www.google.com/reader/api/0/stream/contents/feed/http://www.cnbeta.com/backend.php"
//#define kGRATOMFEED         @"https://www.google.com/reader/atom/feed/http://xkcd.com/rss.xml?n=17"

#define kGRATOMFEED         @"https://www.google.com/reader/api/0/stream/items/contents?i=tag:google.com,2005:reader/item/5c6106e1bd162088&output=json"

@implementation TestOAuth2Controller

@synthesize data = _data, auth = _auth;
@synthesize webView = _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kOAuth2ClientID clientSecret:kOAuth2ClientSecret];
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
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

#pragma mark - action methods
-(IBAction)login:(id)sender{
    
    CustomOAuth2ViewController* controller = [[CustomOAuth2ViewController alloc] initWithScope:kOAuthScope clientID:kOAuth2ClientID clientSecret:kOAuth2ClientSecret keychainItemName:kKeychainItemName delegate:self finishedSelector:@selector(viewController:finishedWithAuth:error:)];

    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentModalViewController:nav animated:YES];
    
}
-(IBAction)logout:(id)sender{
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
    [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];
}
     
-(IBAction)showList:(id)sender{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kGoogleReaderList]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_2) AppleWebKit/534.52.7 (KHTML, like Gecko) Version/5.1.2 Safari/534.52.7" forHTTPHeaderField:@"User-Agent"];
    if ([self.auth canAuthorize]){
        self.data =  [NSMutableData dataWithLength:0];
        [self.auth authorizeRequest:request completionHandler:^(NSError* error){
            [request setTimeoutInterval:10];
            DebugLog(@"authrized request is %@", [request.allHTTPHeaderFields description]);
            [NSURLConnection connectionWithRequest:request delegate:self];  
        }];
    }else{
        DebugLog(@"can't authorize", nil);
    }
}

-(IBAction)showAtomFeed:(id)sender{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kGRATOMFEED]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_2) AppleWebKit/534.52.7 (KHTML, like Gecko) Version/5.1.2 Safari/534.52.7" forHTTPHeaderField:@"User-Agent"];
    if ([self.auth canAuthorize]){
        self.data =  [NSMutableData dataWithLength:0];
        [self.auth authorizeRequest:request completionHandler:^(NSError* error){
            [request setTimeoutInterval:10];
            DebugLog(@"authrized request is %@", [request.allHTTPHeaderFields description]);
            [NSURLConnection connectionWithRequest:request delegate:self];  
        }];
    }else{
        DebugLog(@"can't authorize", nil);
    }
}


#pragma mark - Google OAuth2 call back methods
 - (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
       finishedWithAuth:(GTMOAuth2Authentication *)auth
                  error:(NSError *)error{
     [self dismissModalViewControllerAnimated:YES];
     if (error == nil){
         DebugLog(@"login succeded", nil);
         self.auth = auth;
     }else{
         DebugLog(@"login failed", nil);
         DebugLog(@"%@", [error localizedDescription]);
     }
 }

#pragma mark - URL Connection delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString* str = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    DebugLog(@"%@", str);
//    UIWebView* web = [[UIWebView alloc] initWithFrame:self.view.frame];
//    [self.view addSubview:web];
    [self.webView loadHTMLString:str baseURL:nil];
//    [web release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    DebugLog(@"connection did failed", nil);
    DebugLog(@"%@", [error localizedDescription]);
    [self.webView loadHTMLString:[error localizedDescription] baseURL:nil];
}


@end
