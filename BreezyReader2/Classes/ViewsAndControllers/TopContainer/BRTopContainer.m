//
//  BRTopContainer.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRTopContainer.h"
#import "UIView+util.h"

#define CGPointCenterOfRect(rect) CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2)

static double kTransitionAnimationDuration = 0.2f;

@interface BRTopContainer ()

@property (nonatomic, retain) NSMutableDictionary* boomedTransforms;

@end

@implementation BRTopContainer

@synthesize boomedTransforms = _boomedTransforms;

-(void)dealloc{
    self.boomedTransforms = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.wantsFullScreenLayout = YES;
        self.boomedTransforms = [NSMutableDictionary dictionary];
    }
    return self;
}

-(UIViewController*)topController{
    return [self.childViewControllers lastObject];
}

-(BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers{
    return YES;
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    id last = [self.childViewControllers lastObject];
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        if (obj != last){
            [obj didReceiveMemoryWarning];
        }
    }];
}

-(void)loadView{
    UIView* view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
    view.autoresizesSubviews = NO;
    view.backgroundColor = [UIColor blackColor];
    view.contentMode = UIViewContentModeTop;
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIViewController* controller = [self.childViewControllers lastObject];
    [self.view addSubview:controller.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)zoomOutViewController:(UIViewController*)controller fromRect:(CGRect)rect{
    
}

-(void)addToTop:(UIViewController*)controller{
    UIViewController* top = [self.childViewControllers lastObject];
    [controller willMoveToParentViewController:self];
    [self addChildViewController:controller];
    if (top == nil){
        [self.view addSubview:controller.view];
    }else{
        [self transitionFromViewController:top toViewController:controller duration:0 options:UIViewAnimationOptionTransitionNone animations:^{
//            [self.view addSubview:controller.view];
        }completion:^(BOOL finished){
            if (finished){
                [controller didMoveToParentViewController:self];
            }
        }];
    }
}

-(void)popViewController:(BOOL)animated{
    CGFloat duration = (animated)?0.2f:0.0f;
    
    UIViewController* top = [self.childViewControllers lastObject];
    UIView* topView = top.view;
    if (top){
        [top willMoveToParentViewController:nil];
        [top removeFromParentViewController];
        UIViewController* current = [self.childViewControllers lastObject];
        if (current){
            [self.view insertSubview:current.view belowSubview:topView];
        }
        
        [UIView animateWithDuration:duration animations:^{
            topView.alpha = 0.0f;
        } completion:^(BOOL finished){
            if (finished){
                [topView removeFromSuperview];
                [top didMoveToParentViewController:nil];
            }
        }];

    }
}

-(void)boomOutViewController:(UIViewController*)viewController fromView:(UIView*)fromView{
    
    UIViewController* preController = [self topController];
    
    [viewController willMoveToParentViewController:self];
    [self addChildViewController:viewController];
    
    CGRect fromRect = [fromView convertRect:fromView.bounds toView:self.view];
    CGRect toRect = self.view.bounds;
    CGFloat widthScale = fromRect.size.width/toRect.size.width;
    CGFloat heightScale = fromRect.size.height/toRect.size.height;
    CGPoint fromCenter = CGPointCenterOfRect(fromRect);
    CGPoint toCenter = CGPointCenterOfRect(toRect);
    
    CGAffineTransform translate = CGAffineTransformMakeTranslation(-toCenter.x+fromCenter.x, -toCenter.y+fromCenter.y);
    CGAffineTransform scale = CGAffineTransformMakeScale(widthScale, heightScale);
    
    
    CGAffineTransform transform = CGAffineTransformConcat(scale, translate);
    [self.boomedTransforms setObject:[NSValue valueWithCGAffineTransform:transform] forKey:[NSValue valueWithNonretainedObject:viewController]];
    
    UIView* view = viewController.view;
    
    [self.view addSubview:view];
    view.frame = self.view.bounds;
    view.transform = transform;
    view.alpha = 0;
    
    preController.view.userInteractionEnabled = NO;
    view.userInteractionEnabled = NO;
    
    [self transitionFromViewController:preController toViewController:viewController duration:kTransitionAnimationDuration options:UIViewAnimationOptionCurveEaseIn animations:^{
        viewController.view.transform = CGAffineTransformIdentity;
        viewController.view.alpha = 1;
        preController.view.transform = CGAffineTransformMakeScale(0.9, 0.9);  
    }completion:^(BOOL finished){
        if (finished){
            preController.view.transform = CGAffineTransformIdentity;
            preController.view.userInteractionEnabled = YES;
            view.userInteractionEnabled = YES;
            [viewController didMoveToParentViewController:self];
        }
    }];
}

-(void)boomInTopViewController{
    
    UIViewController* top = [self topController];
    NSInteger index = [self.childViewControllers indexOfObject:top];
    UIViewController* second = nil;
    if (index - 1 >= 0){
        second = [self.childViewControllers objectAtIndex:index-1];
    }
    
    NSValue* key = [NSValue valueWithNonretainedObject:top];
    CGAffineTransform transform = [[self.boomedTransforms objectForKey:key] CGAffineTransformValue];
    [self.boomedTransforms removeObjectForKey:[NSValue valueWithNonretainedObject:key]];
    
    [self.view insertSubview:second.view belowSubview:top.view];
    second.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
    
    top.view.userInteractionEnabled = NO;
    second.view.userInteractionEnabled = NO;
    
    [top willMoveToParentViewController:nil];
    [second viewWillAppear:YES];
    [top viewWillDisappear:YES];
    
    [UIView animateWithDuration:kTransitionAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        top.view.transform = transform; 
        top.view.alpha = 0;
        second.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        second.view.userInteractionEnabled = YES;
        [second viewDidAppear:YES];
        [top.view removeFromSuperview];
        [top viewDidDisappear:YES];
        [top didMoveToParentViewController:nil];
        [top removeFromParentViewController];
    }];
}

-(void)slideInViewController:(UIViewController*)viewController{
    
    UIViewController* currentController = [self topController];
    
    [viewController willMoveToParentViewController:self];
    [self addChildViewController:viewController];
 
    UIView* view = viewController.view;
    
    [self.view addSubview:view];
    
    view.frame = self.view.bounds;
    
    CGAffineTransform translate = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0);
    view.transform = translate;
    
    currentController.view.userInteractionEnabled = NO;
    view.userInteractionEnabled = NO;
    
    [self transitionFromViewController:currentController toViewController:viewController duration:kTransitionAnimationDuration options:UIViewAnimationOptionCurveEaseOut animations:^{
        viewController.view.transform = CGAffineTransformIdentity;
        currentController.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
    }completion:^(BOOL finished){
        if (finished){
            currentController.view.transform = CGAffineTransformIdentity;
            view.userInteractionEnabled = YES;
            [viewController didMoveToParentViewController:self];
        }
    }];
}

-(void)slideOutViewController{
    UIViewController* top = [self topController];
    NSInteger index = [self.childViewControllers indexOfObject:top];
    UIViewController* second = nil;
    if (index - 1 >= 0){
        second = [self.childViewControllers objectAtIndex:index-1];
    }
    
    [self.view addSubview:second.view];
    second.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
    
    top.view.userInteractionEnabled = NO;
    second.view.userInteractionEnabled = NO;
    
    [top willMoveToParentViewController:nil];
    
    [self transitionFromViewController:top toViewController:second duration:kTransitionAnimationDuration options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.view bringSubviewToFront:top.view];
        CGAffineTransform translate = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0);
        top.view.transform = translate;
        second.view.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished){
        if (finished){
            [top removeFromParentViewController];
            [top didMoveToParentViewController:nil];
            second.view.userInteractionEnabled = YES;
        }
    }];
}

@end
