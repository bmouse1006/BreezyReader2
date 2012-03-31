//
//  BRUserVerifyController.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRUserVerifyController.h"
#import "GTMOAuthAuthentication.h"
#import "GoogleAppConstants.h"
#import "GoogleAuthManager.h"

@interface BRUserVerifyController (){
    BOOL _userHasSignedIn;
}

@end

@implementation BRUserVerifyController

@synthesize loginButton = _loginButton;

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.loginButton = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(oauthUserSignedIn:) name:kGTMOAuthUserHasSignedIn object:nil];
        [nc addObserver:self selector:@selector(oauthUserWillSignin:) name:kGTMOAuthUserWillSignIn object:nil];
        [nc addObserver:self selector:@selector(oauthFetchStarted:) name:kGTMOAuthFetchStarted object:nil];
        [nc addObserver:self selector:@selector(oauthFetchStopped:) name:kGTMOAuthFetchStopped object:nil];
        [nc addObserver:self selector:@selector(userSigninFinished:) name:NOTIFICATION_USERSIGNEDINFINISHED object:nil];
        [nc addObserver:self selector:@selector(loginNeeded:) name:LOGINNEEDED object:nil];
    }
    return self;
}

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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - actions
-(IBAction)loginButtonClicked:(id)sender{
    [self loginNeeded:nil];
}

-(IBAction)signout:(id)sender{
    [[GoogleAuthManager shared] logout];
}

#pragma mark - notification call back
-(void)oauthUserSignedIn:(NSNotification*)notification{
//    [self dismissModalViewControllerAnimated:YES];
////    self.loginButton.hidden = YES;
//    [self.topContainer popViewController:NO];
    _userHasSignedIn = YES;
}

-(void)oauthUserWillSignin:(NSNotification*)notification{
    
}

-(void)oauthFetchStarted:(NSNotification*)notification{
    
}

-(void)oauthFetchStopped:(NSNotification*)notification{
//    if (_userHasSignedIn == NO){
//        return;
//    }
//    [self dismissModalViewControllerAnimated:YES];
////    self.loginButton.hidden = YES;
//    [self.topContainer popViewController:NO];
}

-(void)userSigninFinished:(NSNotification*)notification{
    [self dismissModalViewControllerAnimated:YES];
//    self.loginButton.hidden = YES;
    [[self topContainer] popViewController:NO];
    [[GoogleAuthManager shared] getValidToken:NULL];
}

-(void)loginNeeded:(NSNotification*)notification{
    UIViewController* authController = [[GoogleAuthManager shared] GOAuthController];
    UINavigationController* nav = [[[UINavigationController alloc] initWithRootViewController:authController] autorelease];
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

@end
