//
//  BRSubscriptionTileView.m
//  BreezyReader2
//
//  Created by 金 津 on 12-2-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRSubscriptionTileView.h"
#import "BRImagePreviewCache.h"
#import "BROperationQueues.h"
#import "ASIDownloadCache.h"
#import "JJThumbnailCache.h"
#import "UIView+util.h"
#import "BRViewControllerNotification.h"
#import "GoogleReaderClient.h"
#import "BRUserPreferenceDefine.h"
#import <QuartzCore/QuartzCore.h>

//#define DefaultImage_SUB [UIImage imageNamed:@"default_sub"]
#define DefaultImage_SUB [UIImage imageNamed:@"tileview_rss"]

@interface BRSubscriptionTileView (){
    BOOL _isAppearring;
    BOOL _allowAnimation;
    
    BOOL _hasPreview;
    
    NSInteger _unreadCount;
}

//@property (nonatomic, retain) NSTimer* timer;
@property (nonatomic, strong) ASIHTTPRequest* imageRequest;
@property (nonatomic, strong) NSString* currentImageURL;
@property (nonatomic, strong) UIView* unreadCountContainer;
@property (nonatomic, strong) UIImageView* unreadImage;
@property (nonatomic, strong) UIImageView* captionImage;
@property (nonatomic, assign) BOOL allowAnimation;

@property (nonatomic, strong) GoogleReaderClient* grClient;

@property (nonatomic, weak) NSTimer* timer;

@property (nonatomic, strong) UIButton* glowButton;

-(void)createSubviews;

-(void)startFeedRequest:(GRSubscription*)sub;
-(void)startImageSwitching:(NSString*)imageURL;
-(void)startTimer;

-(NSString*)pickARandomImageURL;

-(UIImageView*)prepareImageView;

@end

@implementation BRSubscriptionTileView

@dynamic title;

@synthesize unreadCountContainer = _unreadCountContainer;
@synthesize caption = _caption, infoButton = _infoButton;
@synthesize imageURLs = _imageURLs;
@synthesize imageRequest = _imageRequest;

@synthesize timer = _timer;
@synthesize subscription = _subscription;

@synthesize imageView = _imageView;

@synthesize currentImageURL = _currentImageURL;

@synthesize unreadLabel = _unreadLabel;
@synthesize unreadImage = _unreadImage;
@synthesize captionImage = _captionImage;

@synthesize allowAnimation = _allowAnimation;

@synthesize grClient = _grClient;

@synthesize glowButton = _glowButton;

static CGFloat kCaptionHeight = 40.0f;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [BRUserPreferenceDefine flipThumbnailColor];
        _isAppearring = YES;
        _allowAnimation = YES;
        [self createSubviews];
        [self registerNotifications];
    }
    
    return self;
}

-(void)registerNotifications{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(enableAnimation:) name:NOTIFICATION_ALLOWFLIPANIMATION object:nil];
    [nc addObserver:self selector:@selector(disableAnimation:) name:NOTIFICATION_FORBIDDENFLIPANIMATION object:nil];
    [nc addObserver:self selector:@selector(disableTimers:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [nc addObserver:self selector:@selector(enableTimers:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [nc addObserver:self selector:@selector(filpFinished:) name:NOTIFICATION_FINISHEDFLIPSUBTILEVIEW object:self];
    [nc addObserver:self selector:@selector(updateUnreadCountLabel:) name:NOTIFICAITON_END_UPDATEUNREADCOUNT object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.grClient clearAndCancel];
    [self.layer removeAllAnimations];
    [self.imageRequest clearDelegatesAndCancel];
    self.imageRequest = nil;
    _imageURLs = nil;
    _subscription = nil;
//    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - getter setter
-(void)setImageRequest:(ASIHTTPRequest *)imageRequest{
    if (_imageRequest != imageRequest){
        [_imageRequest clearDelegatesAndCancel];
        _imageRequest = imageRequest;
    }
}

-(NSString*)title{
    return self.caption.text;
}

-(void)setTitle:(NSString *)title{
    self.caption.text = title;
}

-(void)setSubscription:(GRSubscription *)subscription{
    if (_subscription != subscription){
        _subscription = subscription;
        [self.grClient clearAndCancel];
        NSArray* imageURLs = [[BRImagePreviewCache sharedCache] cachedPreviewImagesForKey:_subscription.ID];
        if (imageURLs){
            if ([imageURLs isKindOfClass:[NSNull class]]){
                [self setImageURLs:nil];
            }else{
                [self setImageURLs:[imageURLs mutableCopy]];
            }
        }else{
            [self setImageURLs:nil];
            //start
            [self startFeedRequest:_subscription];
        }
        [self setNeedsLayout];
    }
}

-(void)setAllowAnimation:(BOOL)allowAnimation{
    _allowAnimation = allowAnimation;
    if (_allowAnimation == NO){
        [self.layer removeAllAnimations];
    }
}

#pragma mark - sub views
-(void)layoutSubviews{
    [super layoutSubviews];
    self.caption.shadowEnable = _hasPreview;
    self.unreadLabel.shadowEnable = YES;
    
    self.caption.text = self.subscription.title;
    _unreadCount = [GoogleReaderClient unreadCountWithID:self.subscription.ID];
    if (_unreadCount){
        [self.unreadImage removeFromSuperview];
        self.unreadLabel.text = [[NSNumber numberWithInt:_unreadCount] description];
        self.unreadImage = [[UIImageView alloc] initWithImage:[self.unreadLabel snapshot]];
        CGRect frame = self.unreadImage.frame;
        frame.origin.x = 5.0;
        frame.origin.y = 5.0;
        self.unreadCountContainer.frame = frame;
        
        [self.unreadCountContainer addSubview:self.unreadImage];
        
    }else{
        [self.unreadImage removeFromSuperview];
//        self.unreadCountContainer.frame = CGRectZero;
    }
    
    /*
    if (urCount == 0){
        self.unreadLabel.text = nil;
        [self.unreadImage setFrame:CGRectZero];
    }else{
        self.unreadLabel.text = [[NSNumber numberWithInt:urCount] description];
        CGRect frame = self.unreadLabel.frame;
        frame.origin.y = 5;
//        frame.origin.x = self.frame.size.width - 5 - frame.size.width;
        frame.origin.x = 5;
        [self.unreadLabel setFrame:frame];
        [self.unreadImage setFrame:frame];
        self.unreadImage.image = [self.unreadLabel snapshot];
    }*/
    if (self.caption.text.length > 0){
        CGRect frame = CGRectMake(0,self.bounds.size.height-kCaptionHeight, self.bounds.size.width, kCaptionHeight);
        [self.caption setFrame:frame];
    }else{
        [self.caption setFrame:CGRectZero];
    }
    self.captionImage.frame = self.caption.frame;
    self.captionImage.image = [self.caption snapshot];
    
}

-(void)createSubviews{
    
    self.imageView = [[UIImageView alloc] initWithImage:DefaultImage_SUB];
    self.imageView.alpha = 0.3f;
    
    self.caption = [[JJLabel alloc] initWithFrame:CGRectZero];
    self.caption.backgroundColor = [UIColor clearColor];
    self.caption.textColor = [UIColor whiteColor];
    self.caption.font = [UIFont boldSystemFontOfSize:14];
    self.caption.textColor = [UIColor whiteColor];
    self.caption.textAlignment = UITextAlignmentCenter;
    self.caption.verticalAlignment = JJTextVerticalAlignmentBottom;
    self.caption.shadowBlur = 2;
    self.caption.shadowColor = [UIColor blackColor];
    self.caption.shadowOffset = CGSizeMake(1, 1);
    self.caption.shadowEnable = NO;
    UIEdgeInsets insets = UIEdgeInsetsMake(2, 5, 2, 5);
    [self.caption setContentEdgeInsets:insets];
    
    self.captionImage = [[UIImageView alloc] initWithFrame:self.caption.frame];
    self.captionImage.backgroundColor = [UIColor clearColor];
    
    self.unreadLabel = [[JJLabel alloc] initWithFrame:CGRectZero];
    self.unreadLabel.backgroundColor = [UIColor clearColor];
    self.unreadLabel.shadowBlur = 2;
    self.unreadLabel.shadowColor = [UIColor blackColor];
    self.unreadLabel.shadowOffset = CGSizeMake(1, 1);
    self.unreadLabel.shadowEnable = NO;
    self.unreadLabel.clipsToBounds = YES;
    self.unreadLabel.font = [UIFont boldSystemFontOfSize:12];
    self.unreadLabel.autoResize = YES;
    self.unreadLabel.textColor = [UIColor whiteColor];
    [self.unreadLabel setContentEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 2)];
    
//    self.unreadImage = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    self.unreadCountContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.unreadCountContainer.backgroundColor = [UIColor clearColor];
    
    self.infoButton = [[UIButton alloc] initWithFrame:CGRectMake(-7, -7, 32, 32 )];
    [self.infoButton setImage:[UIImage imageNamed:@"info"] forState:UIControlStateNormal];
    self.infoButton.showsTouchWhenHighlighted = YES;
    self.infoButton.alpha = 0.6f;
    [self.infoButton addTarget:self action:@selector(infoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    CGRect frame = self.infoButton.frame;
    frame.origin.x += 5;
    frame.origin.y += 5;
    self.infoButton.frame = frame;
    
    self.glowButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.glowButton.highlighted = YES;
    self.glowButton.showsTouchWhenHighlighted = YES;
    self.glowButton.backgroundColor = [UIColor clearColor];
    self.glowButton.hidden = YES;
    
    [self addSubview:self.imageView];
//    [self addSubview:self.caption];
//    [self addSubview:self.unreadImage];
//    [self addSubview:self.infoButton];
    [self addSubview:self.captionImage];
    
    [self addSubview:self.unreadCountContainer];
    
    [self addSubview:self.glowButton];
}

-(void)requestFinished:(ASIHTTPRequest*)request{
    UIImage* image = [UIImage imageWithData:request.responseData];
    CGSize imageSize = image.size;
    CGSize frameSize = self.frame.size;
    BOOL suitableImg = (imageSize.width >= frameSize.width && imageSize.height >= frameSize.height);
    
    if (suitableImg == NO){
        [self.imageURLs removeObject:[request.originalURL absoluteString]];
        [[BRImagePreviewCache sharedCache] storeImagePreviews:self.imageURLs key:self.subscription.ID];
        if ([self.imageURLs count] > 0){
            [self startImageSwitching:[self.imageURLs objectAtIndex:0]];
        }
    }else{
        UIImageView* imageView = [self prepareImageView];
        image = [JJThumbnailCache storeThumbnail:image forURL:request.originalURL size:self.bounds.size];
        imageView.image = image;
        [self switchSubviewFrom:self.imageView toView:imageView];
        _hasPreview = YES;
        self.imageView = imageView;
        [self performSelectorOnMainThread:@selector(startTimer) withObject:nil waitUntilDone:NO];
    }
    
}

-(void)requestFailed:(ASIHTTPRequest*)request{
    [self.imageURLs removeObject:[request.url absoluteString]];
    [[BRImagePreviewCache sharedCache] storeImagePreviews:self.imageURLs key:self.subscription.ID];
    if ([self.imageURLs count] > 0){
        [self startImageSwitching:[self.imageURLs objectAtIndex:0]];
    }
}

-(void)switchSubviewFrom:(UIView*)original toView:(UIView*)destiny{
    @synchronized(self){
        [self addSubview:destiny];
        
        if (_allowAnimation == NO){
            [original removeFromSuperview];
        }else{
            [UIView transitionFromView:original toView:destiny duration:0.4 options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished){
                if (original.superview != nil){
                    [original removeFromSuperview];
                }
            }];
        }
//        [self bringSubviewToFront:self.infoButton];
        [self bringSubviewToFront:self.unreadCountContainer];
        [self bringSubviewToFront:self.captionImage];
    }
}

-(void)setImageURLs:(NSMutableArray *)imageURLs{
    if(_imageURLs != imageURLs){
        [self.layer removeAllAnimations];
//        [self.timer invalidate];
        _imageURLs = imageURLs;
        //start load images
        [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:DefaultImage_SUB waitUntilDone:NO];
        self.imageView.alpha = 0.3f;
        _hasPreview = NO;
        if ([_imageURLs count] > 0){
            [self startImageSwitching:[_imageURLs objectAtIndex:0]];
        }
    }
}

-(UIImageView*)prepareImageView{
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    imageView.image = DefaultImage_SUB;
    imageView.clipsToBounds = YES;
    
    return imageView;
}

-(void)startImageSwitching:(NSString*)imageURL{
    [self.imageRequest clearDelegatesAndCancel];
    self.currentImageURL = imageURL;
    UIImage* image = [JJThumbnailCache thumbnailForURL:[NSURL URLWithString:imageURL] andSize:self.bounds.size];
    if (image != nil){
        UIImageView* imageView = [self prepareImageView];
        imageView.image = image;
        [self switchSubviewFrom:self.imageView toView:imageView];
        self.imageView = imageView;
        _hasPreview = YES;
        [self performSelectorOnMainThread:@selector(startTimer) withObject:nil waitUntilDone:NO];
        return;
    }else{
        self.imageRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:self.currentImageURL]];
        self.imageRequest.cachePolicy = ASIOnlyLoadIfNotCachedCachePolicy;
        self.imageRequest.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
        self.imageRequest.delegate = self;
        [self.imageRequest startAsynchronous];
    }
}

-(void)changeImage:(NSTimer*)timer{
    if (self.timer == timer){

        if (_isAppearring == NO || [BRUserPreferenceDefine shouldAutoFlipThumbnail] == NO){
            [self performSelectorOnMainThread:@selector(startTimer) withObject:nil waitUntilDone:NO];
            return;
        }
        @synchronized(self){
            if ([self.imageURLs count] <= 1){
                return;
            }
            NSInteger currentIndex = [self.imageURLs indexOfObject:self.currentImageURL];
            if (currentIndex == NSNotFound){
                return;
            }
            currentIndex = (currentIndex + 1 >= [self.imageURLs count])?0:currentIndex+1;
            
            [self startImageSwitching:[self.imageURLs objectAtIndex:currentIndex]];
        }
        
    }
}

-(void)startFeedRequest:(GRSubscription*)sub{
    [self setImageURLs:nil];
    [self.grClient clearAndCancel];
    self.grClient = [GoogleReaderClient clientWithDelegate:self action:@selector(receivedGRResponse:)];
    [self.grClient requestFeedWithIdentifier:sub.ID count:[NSNumber numberWithInt:2] startFrom:nil exclude:nil continuation:nil forceRefresh:YES needAuth:YES];
}

-(void)setObject:(id)obj{
    GRSubscription* sub = obj;
    if ([sub isKindOfClass:[GRSubscription class]]){
        self.subscription = sub;
    }
}

-(NSString*)pickARandomImageURL{
    if ([self.imageURLs count] > 0){
        NSInteger index = arc4random() % [self.imageURLs count];
        return [self.imageURLs objectAtIndex:index];
    }else{
        return nil;
    }
}

#pragma mark - timer
-(void)startTimer{
    [self.imageRequest clearDelegatesAndCancel];
//    self.timer = nil;
    NSTimeInterval interval = (arc4random() % 7)+7;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(changeImage:) userInfo:nil repeats:NO];
//    [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(changeImage) userInfo:nil repeats:NO];
}

#pragma mark - responder actions
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    [self bringSubviewToFront:self.glowButton];
    self.glowButton.hidden = NO;
    self.glowButton.center = [touch locationInView:self];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.glowButton.alpha = 0.0f;
    } completion:^(BOOL finished){
        self.glowButton.alpha = 1.0f;
        self.glowButton.hidden = YES;
    }];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
}

#pragma mark - control action
-(void)thumbTouchedDown:(id)sender{
    CGAffineTransform scale = CGAffineTransformMakeScale(0.95, 0.95);
    
    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = scale;
    } completion:NULL];
}

-(void)thumbTouched:(id)sender{
    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:NULL];
}

-(void)thumbTouchMoveOut:(id)sender{
    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:NULL];    
}



-(void)infoButtonClicked:(id)sender{
    //start filp animation
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:self.subscription forKey:@"subscription"];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STARTFLIPSUBTILEVIEW object:self userInfo:userInfo];
    self.hidden = YES;
    [self disableTimers:nil];
}

#pragma mark - view life circle
-(void)willDisappear:(BOOL)animated{
    _isAppearring = NO;
    self.allowAnimation = NO;
    
}

-(void)didDisappear:(BOOL)animated{
}

-(void)willAppear:(BOOL)animated{

}

-(void)didAppear:(BOOL)animated{
    _isAppearring = YES;
    self.allowAnimation = YES;
}

#pragma mark - notification call back
-(void)updateUnreadCountLabel:(NSNotification*)notification{
    NSInteger count = [GoogleReaderClient unreadCountWithID:self.subscription.ID];
    
    if (count == _unreadCount){
        return;
    }
    
     _unreadCount = count;
    
    [self.unreadCountContainer.layer removeAllAnimations];
    UIView* previousUnreadView = self.unreadImage;
    self.unreadLabel.text = [[NSNumber numberWithInt:count] description];
    self.unreadImage = (count == 0)?nil:[[UIImageView alloc] initWithImage:[self.unreadLabel snapshot]];
    CGRect frame = self.unreadImage.frame;
    frame.origin.x = 5.0;
    frame.origin.y = 5.0;
    self.unreadCountContainer.frame = frame;
    [self.unreadCountContainer addSubview:self.unreadImage];

    [UIView transitionFromView:previousUnreadView toView:self.unreadImage duration:0.4f options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished){
        if (finished){
            [previousUnreadView removeFromSuperview];
        }
    }];
}

-(void)enableAnimation:(NSNotification*)notification{
    self.allowAnimation = YES;
}

-(void)disableAnimation:(NSNotification*)notification{
    self.allowAnimation = NO;
}

-(void)enableTimers:(NSNotification*)notification{
    [self startTimer];
}

-(void)disableTimers:(NSNotification*)notification{
    [self.layer removeAllAnimations];
//    [self.timer invalidate];
}

-(void)filpFinished:(NSNotification*)notification{
    self.hidden = NO;
    [self enableTimers:nil];
}

#pragma mark - google reader delegate method
-(void)receivedGRResponse:(GoogleReaderClient*)client{
    DebugLog(@"feed reading completed", nil);
    if (client.error){
        DebugLog(@"error happened %@", [client.error localizedDescription]);
        [[BRImagePreviewCache sharedCache] storeImagePreviews:[NSNull null] key:self.subscription.ID];
        return;
    }
    
    GRFeed* feed = client.responseFeed;
    if (feed){
        DebugLog(@"feed's ID is %@", feed.ID);
        [[BRImagePreviewCache sharedCache] storeImagePreviews:feed.imageURLs key:self.subscription.ID];
        NSMutableArray* images = [feed.imageURLs mutableCopy];
        [self setImageURLs:images];
    }
}

@end
