//
//  WBWeiboComposeViewController.m
//  SocialAuthTest
//
//  Created by Jin Jin on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WBWeiboComposeViewController.h"
#import "Draft.h"
#import "WeiboClient.h"
#import "OAuthEngine.h"
#import "OAuthController.h"
#import "BaseAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "WeiboCommonDefine.h"

#define kWeiboOAuthConsumerKey      @"899283629" //replace
#define kWeiboOAuthConsumerSecret   @"fd35ec9563f631cd5ecfb2a1dda8cc9c" //replace
#define kWeiboOAuthStoreKey @"kWeiboOAuthStoreKey"

@interface WBWeiboComposeViewController (){
    UIStatusBarStyle _previousStatusBarStyle;
    BOOL _autoPromoteAuthController;
    UIModalPresentationStyle _previousPresentationStyle;
}

@property (nonatomic, assign) UIViewController* rootController;
@property (nonatomic, retain) OAuthEngine* weiboEngine;

@property (nonatomic, copy) NSString* initialText;
@property (nonatomic, retain) UIImage* image;
@property (nonatomic, copy) NSString* urlString;

@end

@implementation WBWeiboComposeViewController

@synthesize composeDialog = _composeDialog, backgroundView = _backgroundView;
@synthesize toolBar = _toolbar;
@synthesize sepertorLine = _sepertorLine, titleLabel = _titleLabel;
@synthesize contentView = _contentView, contentContainer = _contentContainer;
@synthesize textView = _textView, contentImageView = _contentImageView;
@synthesize checkedButton = _checkedButton;
@synthesize rootController = _rootController;
@synthesize weiboEngine = _weiboEngine;
@synthesize initialText = _initialText, image = _image, urlString = _urlString;

-(void)dealloc{
    self.composeDialog = nil;
    self.backgroundView = nil;
    self.toolBar = nil;
    self.sepertorLine = nil;
    self.titleLabel = nil;
    self.contentImageView = nil;
    self.contentContainer = nil;
    self.textView = nil;
    self.contentView = nil;
    self.checkedButton = nil;
    self.weiboEngine = nil;
    self.initialText = nil;
    self.image = nil;
    self.urlString = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.wantsFullScreenLayout = YES;
        _autoPromoteAuthController = YES;
        self.weiboEngine = [[[OAuthEngine alloc] initOAuthWithDelegate:self] autorelease];
        self.weiboEngine.consumerKey = kWeiboOAuthConsumerKey;
        self.weiboEngine.consumerSecret = kWeiboOAuthConsumerSecret;
    }
    return self;
}

+(id)sharedController{
    static dispatch_once_t onceToken;
    static WBWeiboComposeViewController* controller = nil;
    dispatch_once(&onceToken, ^{
        controller = [[WBWeiboComposeViewController alloc] initWithNibName:@"WBWeiboComposeViewController" bundle:nil];
    });
    
    return controller;
}

//+(id)controller{
//    WBWeiboComposeViewController* controller = [[[WBWeiboComposeViewController alloc] initWithNibName:@"WBWeiboComposeViewController" bundle:nil] autorelease];
//
//    return controller;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.cornerRadius = 12.0f;
    
    self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_background_pattern"]];
    
    self.titleLabel.text = WeiboLocalizedString(@"Sina Weibo", nil);
    self.titleLabel.shadowColor = [UIColor whiteColor];
    self.titleLabel.shadowOffset = CGSizeMake(0, 1);
    CGRect frame = self.sepertorLine.frame;
    frame.origin.x = 10;
    frame.origin.y = 37;
    frame.size.height = 0.5f;
    frame.size.width = self.contentView.frame.size.width - 20.0f;
    self.sepertorLine.frame = frame;
    self.sepertorLine.backgroundColor = [UIColor lightGrayColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:animated];
    
    NSString* content = (self.urlString.length > 0)?[NSString stringWithFormat:@"%@ %@", self.initialText, self.urlString]:self.initialText;
    
    self.textView.text = content;
    self.contentImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.contentImageView.image = self.image;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle animated:animated];
    self.contentContainer.layer.shadowOpacity = 0.0f;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.contentContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentContainer.layer.shadowOffset = CGSizeMake(0, 0);
    self.contentContainer.layer.shadowOpacity = 0.8f;
    self.contentContainer.layer.shadowRadius = 5.0f;
    
    //check if weibo is authorized
    if ([self.weiboEngine isAuthorized] == NO && _autoPromoteAuthController){
        OAuthController* controller = [OAuthController controllerToEnterCredentialsWithEngine:self.weiboEngine delegate:self];
        controller.delegate = self;
        [self presentViewController:controller animated:YES completion:NULL];
        _autoPromoteAuthController = NO;
    }else{
        [self.textView becomeFirstResponder];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)addInitialText:(NSString*)text{
    NSInteger length = MIN(140, text.length);
    NSRange range = {0, length};
    self.initialText = [text substringWithRange:range];
}

-(void)addImage:(UIImage*)image{
    self.image = image;
}

-(void)addURLString:(NSString *)urlString{
    self.urlString = urlString;
}

-(void)show:(BOOL)animated{
    _autoPromoteAuthController = YES;
    self.rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
    _previousPresentationStyle = self.rootController.modalPresentationStyle;
    self.rootController.modalPresentationStyle = UIModalPresentationCurrentContext; 
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.rootController presentViewController:self animated:YES completion:NULL];
}

-(void)dismiss:(BOOL)animated{
    [self dismissViewControllerAnimated:YES completion:^{
        self.rootController.modalPresentationStyle = _previousPresentationStyle;
    }];
}

-(IBAction)share:(id)sender{
    [self postWeiboMessage:self.textView.text image:self.contentImageView.image];
    [self dismiss:YES];
}

-(IBAction)close:(id)sender{
    [self dismiss:YES];
}

#pragma mark - text view delegate
-(void)textViewDidChange:(UITextView *)textView{
    if (self.textView.text.length >= 140){
        NSRange range = {0, 140};
        self.textView.text = [self.textView.text substringWithRange:range];
    }
}

#pragma mark - weibo api

-(void)postWeiboMessage:(NSString*)message image:(UIImage*)image{
    WeiboClient *client = [[WeiboClient alloc] initWithTarget:self 
													   engine:self.weiboEngine
													   action:@selector(postStatusDidFinish:obj:)];
    if (image){
        NSData* jpegImage = UIImageJPEGRepresentation(image, 0.7);
        [client upload:jpegImage status:message];
    }else{
        [client post:message];
    }
}

- (void)postStatusDidFinish:(WeiboClient*)sender obj:(NSObject*)obj{
    //weibo call back
    BaseAlertView* alert = [BaseAlertView loadFromBundle];
    if (sender.errorDetail.length > 0){
        alert.message = WeiboLocalizedString(@"Weibo send failed!", nil);
    }else{
        alert.message = WeiboLocalizedString(@"Weibo send succeeded!", nil);
    }
    [alert show];
}



#pragma mark OAuthEngineDelegate
- (void) storeCachedOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject: data forKey: kWeiboOAuthStoreKey];
	[defaults synchronize];
}

- (NSString *) cachedOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey:kWeiboOAuthStoreKey];
}

- (void)removeCachedOAuthDataForUsername:(NSString *) username{
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults removeObjectForKey:kWeiboOAuthStoreKey];
	[defaults synchronize];
}
//=============================================================================================================================
#pragma mark OAuthSinaWeiboControllerDelegate
- (void) OAuthController: (OAuthController *) controller authenticatedWithUsername: (NSString *) username {
	NSLog(@"Authenicated for %@", username);
}

- (void) OAuthControllerFailed: (OAuthController *) controller {
	NSLog(@"Authentication Failed!");
    BaseAlertView* alert = [BaseAlertView loadFromBundle];
    alert.message = WeiboLocalizedString(@"Authentication Failed!", nil);
    [alert show];
    [controller dismissViewControllerAnimated:YES completion:^{
        [self dismiss:YES];
    }];
	
}

- (void) OAuthControllerCanceled: (OAuthController *) controller {
	NSLog(@"Authentication Canceled.");
    [controller dismissViewControllerAnimated:YES completion:^{
        [self dismiss:YES];
    }];
}

@end
