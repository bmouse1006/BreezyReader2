//
//  JJMediaThumbView.m
//  MeetingPlatform
//
//  Created by  on 12-2-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJMediaThumbView.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"

static CGFloat kCaptionHeight = 20;
static CGFloat kImageSwitchDuration = 0.2;

@interface JJMediaThumbView (){
    BOOL _isAppearring;
}

@property (nonatomic, retain) ASIHTTPRequest* request;

-(ASIHTTPRequest*)requestWithImageURL:(NSString*)urlString;
-(void)switchToImage:(UIImage*)image animated:(BOOL)animated;

@end

@implementation JJMediaThumbView

@synthesize type = _type, captionLabel = _captionLabel, imageView = _imageView;
@synthesize imageURL = _imageURL;
@synthesize request = _request;

-(id)init{
    return [self initWithFrame:CGRectZero];
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        
        self.imageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        [self addSubview:self.imageView];
        
        self.captionLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.captionLabel.font = [UIFont systemFontOfSize:10];
        self.captionLabel.textColor = [UIColor whiteColor];
        self.captionLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        [self addSubview:self.captionLabel];
        [self bringSubviewToFront:self.captionLabel];
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        _isAppearring = YES;
    }
    
    return self;
}

-(void)dealloc{
    self.captionLabel = nil;
    self.imageView = nil;
    self.imageURL = nil;
    [self.request cancel];
    self.request = nil;
    [super dealloc];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    //lay out caption
    CGRect frame = CGRectZero;
    if (self.captionLabel.text.length > 0){
        frame.origin.x = 0;
        frame.origin.y = self.frame.size.height - kCaptionHeight;
        frame.size.width = self.frame.size.width;
        frame.size.height = kCaptionHeight;
    }
    self.captionLabel.frame = frame;
    self.imageView.frame = self.bounds;
}

-(void)setImageURL:(NSString *)imageURL{
    if (_imageURL != imageURL){
        [_imageURL release];
        _imageURL = [imageURL copy];
        self.imageView.image = nil;
        if (_imageURL){
            [self.request cancel];
            self.request = [self requestWithImageURL:_imageURL];
            [self.request startAsynchronous];
        }
    }
}

-(ASIHTTPRequest*)requestWithImageURL:(NSString*)urlString{
    ASIHTTPRequest* request = nil;
    if (urlString.length > 0){
        request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString] usingCache:[ASIDownloadCache sharedCache]];
        request.cachePolicy = ASIOnlyLoadIfNotCachedCachePolicy;
        request.cacheStoragePolicy = ASICacheForSessionDurationCacheStoragePolicy;
        [request setCompletionBlock:^{
            UIImage* image = [UIImage imageWithData:request.responseData];
            [self switchToImage:image animated:!request.didUseCachedResponse];
        }];
    }
    
    return request;
}

-(void)switchToImage:(UIImage*)image animated:(BOOL)animated{
    self.imageView.image = image;
    if (animated == YES){
        self.imageView.alpha = 0;
        [UIView animateWithDuration:kImageSwitchDuration animations:^{
            self.imageView.alpha = 1;
        }];
    }
}

-(void)clear{
    self.imageURL = nil;
    self.captionLabel.text = nil;
}

-(void)setObject:(id)obj{
    id<JJMedia> media = (id<JJMedia> )obj;
    self.captionLabel.text = [media caption];
    self.imageURL = [media thumbUrl];
    self.type = [media mediaType];
}

-(void)thumbTouched:(id)sender{
    
}
-(void)thumbTouchedDown:(id)sender{
    
}

-(void)thumbTouchMoveOut:(id)sender{
    
}

-(void)willDisappear:(BOOL)animated{
    
}

-(void)didDisappear:(BOOL)animated{
    
}

-(void)willAppear:(BOOL)animated{
    
}

-(void)didAppear:(BOOL)animated{
    
}

@end
