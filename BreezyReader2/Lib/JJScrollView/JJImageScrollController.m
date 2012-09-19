//
//  JJImageScrollController.m
//  BreezyReader2
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJImageScrollController.h"
#import "JJImageZoomView.h"
#import <QuartzCore/QuartzCore.h>

@interface JJImageScrollController (){
    BOOL _outletHidden;
}

@property (nonatomic, strong) UITapGestureRecognizer* singleTap;

@end

@implementation JJImageScrollController


@synthesize scrollView = _scrollView;
@synthesize imageList = _imageList;
@synthesize index = _index;
@synthesize singleTap = _singleTap;

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.wantsFullScreenLayout = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oritationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
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


// Implement loadView to create a view hierarchy programmatically, without using a nib.

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView = [[JJPageScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.datasource = self;
    self.scrollView.delegate = self;
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singelTapAction:)];
    [self.scrollView addGestureRecognizer:self.singleTap];
    [self.view addSubview:self.scrollView];
    self.scrollView.pageIndex = self.index;
    [self.scrollView reloadData];  
    
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.scrollView = nil;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:animated];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self oritationDidChange:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

-(UIImage*)imageAtIndex:(NSInteger)index{
    JJImageZoomView* imageView = (JJImageZoomView*)[self.scrollView pageAtIndex:index];
    return imageView.loadedImage;
}

-(void)singleTagAction:(UITapGestureRecognizer*)singleTap{
    
}

#pragma mark - image scroll view delegate method
-(void)scrollView:(JJPageScrollView *)scrollView didScrollToPageAtIndex:(NSInteger)index{

}

-(void)scrollViewWillStartDragging:(JJPageScrollView *)scrollView{
    
}

#pragma mark - image scroll view data source
-(NSUInteger)numberOfPagesInScrollView:(JJPageScrollView*)scrollView{
    return [self.imageList count];
}

-(UIView*)scrollView:(JJPageScrollView*)scrollView pageAtIndex:(NSInteger)index{
    NSLog(@"%@", NSStringFromCGRect(self.scrollView.bounds));
    JJImageZoomView* imageView = [[JJImageZoomView alloc] initWithFrame:self.scrollView.bounds];
    for (UIGestureRecognizer* gesutre in imageView.gestureRecognizers){
        [self.singleTap requireGestureRecognizerToFail:gesutre];
    }
    [imageView setImageURL:[self.imageList objectAtIndex:index]];
    return imageView;
}

-(CGSize)scrollView:(JJPageScrollView*)scrollView sizeOfPageAtIndex:(NSInteger)index{
    return self.scrollView.bounds.size;
}

-(void)setImageList:(NSArray *)imageList startIndex:(NSInteger)index{
    self.imageList = imageList;
    self.index = index;
}

#pragma mark - orientation notification
-(void)oritationDidChange:(NSNotification*)notification{
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationLandscapeLeft:
            //rotation -90
        {
            [UIView animateWithDuration:0.2f animations:^{
                self.scrollView.bounds = CGRectMake(0, 0, height, width);
                self.scrollView.transform = CGAffineTransformMakeRotation(M_PI/2);
                [self.scrollView reloadData];
            }];
        }
            break;
        case UIDeviceOrientationLandscapeRight:
            //rotation 90
        {
            [UIView animateWithDuration:0.2f animations:^{
                self.scrollView.bounds = CGRectMake(0, 0, height, width);
                self.scrollView.transform = CGAffineTransformMakeRotation(-M_PI/2);
                [self.scrollView reloadData];
            }];
        }
            break;
        case UIDeviceOrientationPortrait:
        {
            [UIView animateWithDuration:0.2f animations:^{
                self.scrollView.bounds = CGRectMake(0, 0, width, height);
                self.scrollView.transform = CGAffineTransformIdentity;
                [self.scrollView reloadData];
            }];
        }
            //rotation no
            break;
        default:
            break;
    }
}

-(BOOL)shouldAutorotateImage{
    return NO;
}

@end
