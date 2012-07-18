//
//  ImageScrollView.m
//  eManual
//
//  Created by  on 12-2-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJImageZoomView.h"
#import "ASIHTTPRequest.h"
#import "JJImageView.h"

@interface JJImageZoomView (){
    BOOL _imageLoaded;
    long long _downloadedLength;
    long long _contentLength;
}

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) ASIHTTPRequest* request;
@property (nonatomic, strong) UIProgressView* progressBar;

-(void)setupViews;
- (void)setMaxMinZoomScalesForCurrentBounds;
-(CGPoint)maximumContentOffset;
-(CGPoint)minimumContentOffset;
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale;
-(void)adjustImageView;
-(void)setZoomScale:(float)scale toPoint:(CGPoint)point animated:(BOOL)animated;

@end

@implementation JJImageZoomView

@synthesize imageView = _imageView;
@synthesize request = _request;
@synthesize progressBar = _progressBar;
@synthesize loadedImage;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupViews];        
    }
    
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self setupViews];
}

-(void)dealloc{
    [self.request clearDelegatesAndCancel];
}

-(void)setupViews{
    _downloadedLength = 0.0f;
    _contentLength = 0.0001f;
    self.progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progressBar.progress = 0;
    CGRect frame = self.progressBar.frame;
    frame.origin.x = (self.frame.size.width - frame.size.width)/2;
    frame.origin.y = (self.frame.size.height - frame.size.height)/2;
    [self addSubview:self.progressBar];
    self.progressBar.frame = frame;
    self.progressBar.hidden = YES;
    self.delegate = self;
    self.bouncesZoom = YES;
    self.bounces = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delaysTouchesBegan = YES;
    [self addGestureRecognizer:doubleTap];
}

-(void)setImage:(UIImage *)image{
    [self.imageView removeFromSuperview];
    self.imageView = [[UIImageView alloc] initWithImage:image];
    [self insertSubview:self.imageView belowSubview:self.progressBar];
    
    [self adjustImageView];
}

-(void)setImageURL:(NSString*)imageURL{
    self.progressBar.hidden = YES;
    [self.request clearDelegatesAndCancel];
    self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageURL]];
    self.request.cachePolicy = ASIOnlyLoadIfNotCachedCachePolicy;
    self.request.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
    self.request.allowResumeForFileDownloads =  YES;
    self.request.delegate = self;
    self.request.downloadProgressDelegate = self;
    self.request.didStartSelector = @selector(requestLoadStarted:);
    self.request.didFinishSelector = @selector(requestLoadFinished:);
    [self.request startAsynchronous];
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    _downloadedLength = 0.0f;
    _contentLength = [[responseHeaders objectForKey:@"Content-Length"] longLongValue];
    if (_contentLength == 0){
        _contentLength = LONG_LONG_MAX;
    }
}

-(void)requestLoadFinished:(ASIHTTPRequest*)request{
    _imageLoaded = YES;
    self.progressBar.hidden = YES;
    [self setImage:[UIImage imageWithData:self.request.responseData]];
}

-(void)requestLoadStarted:(ASIHTTPRequest*)request{
    _imageLoaded = NO;
    self.progressBar.progress = 0.0f;
    self.progressBar.hidden = NO;
    [self setImage:[UIImage imageNamed:@"photoDefault"]];
}

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes{
    _downloadedLength += bytes;
    self.progressBar.progress = ((double)_downloadedLength)/_contentLength;
}

// Called when a request needs to change the length of the content to download
//- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength;

-(void)adjustImageView{
    CGSize imageSize = self.imageView.image.size;
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
    [self setNeedsLayout];
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    // center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame = frameToCenter;
    [self bringSubviewToFront:self.progressBar];
    
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = self.imageView.bounds.size;
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    //    minScale /= self.imageView.image.scale;
    
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    CGFloat maxScale = 2.0 / [[UIScreen mainScreen] scale];
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.) 
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    self.minimumZoomScale = minScale;
    self.maximumZoomScale = maxScale;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

// Adjusts content offset and scale to try to preserve the old zoomscale and center.
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale
{    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    self.zoomScale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, oldScale));
    
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:oldCenter fromView:self.imageView];
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0, 
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
    offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
    self.contentOffset = offset;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

-(void)imageViewDidFinishLoad:(id)imageView{
    [self adjustImageView];
}

-(UIImage*)loadedImage{
    UIImage* image = (_imageLoaded)?self.imageView.image:nil;
    return image;
}

-(void)doubleTapAction:(UITapGestureRecognizer*)gesture{
    //    CGPoint location = [gesture locationInView:self.superview];
    if (self.zoomScale == self.minimumZoomScale){
        [self setZoomScale:self.minimumZoomScale*2 animated:YES];
    }else{
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
}

#pragma mark - zoom
-(void)setZoomScale:(float)scale toPoint:(CGPoint)point animated:(BOOL)animated{
//    CGRect rect = CGRect
    CGRect rect = CGRectMake(point.x, point.y, 0, 0);
    [self zoomToRect:rect animated:YES];
}

@end
