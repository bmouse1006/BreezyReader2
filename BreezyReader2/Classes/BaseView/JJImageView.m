//
//  JJImageView.m
//  BreezyReader2
//
//  Created by 金 津 on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJImageView.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "JJThumbnailCache.h"
#import "BROperationQueues.h"

@interface JJImageView ()

@property (nonatomic, retain) ASIHTTPRequest* request;

@property (nonatomic, assign) UIViewContentMode imageContentMode;

-(ASIHTTPRequest*)requestWithURL:(NSURL*)url;

@end

@implementation JJImageView

@synthesize defaultImage = _defaultImage, imageURL = _imageURL;
@synthesize request = _request;
@synthesize delegate = _delegate;
@synthesize defautImageMode = _defautImageMode, imageContentMode = _imageContentMode;

-(void)dealloc{
    [_imageURL release];
    _imageURL = nil;
    self.delegate = nil;
    self.defaultImage = nil;
    [self.request clearDelegatesAndCancel];
    self.request.delegate = nil;
    self.request = nil;
    [super dealloc];
}

-(void)setImageURL:(NSURL *)imageURL{
    if (_imageURL != imageURL){
        [_imageURL release];
        _imageURL = [imageURL retain];
        [self.request clearDelegatesAndCancel];
        if (imageURL != nil){
            __block typeof(self) blockSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage* image = [JJThumbnailCache thumbnailForURL:imageURL andSize:self.bounds.size];
                if (image != nil){
                    [blockSelf changeToLoadedImage:image];
                    [blockSelf.delegate imageDidFinishLoading:blockSelf];
                }else{
                    [blockSelf changeToDefaultImage];
                    blockSelf.request = [blockSelf requestWithURL:imageURL];
                    [blockSelf.request startAsynchronous];
                } 
            });
        }else{
            [self changeToDefaultImage];
        }
    }
}

-(ASIHTTPRequest*)requestWithURL:(NSURL*)url{
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
    request.cachePolicy = ASIOnlyLoadIfNotCachedCachePolicy;
    request.cacheStoragePolicy = ASICacheForSessionDurationCacheStoragePolicy;
    request.delegate = self;
    return request;
}

-(void)changeToDefaultImage{
    self.imageContentMode = self.contentMode;
    self.contentMode = self.defautImageMode;
    [self performSelectorOnMainThread:@selector(setImage:) withObject:self.defaultImage waitUntilDone:NO];
}

-(void)changeToLoadedImage:(UIImage*)image{
    self.contentMode = self.imageContentMode;
    [self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
}

#pragma mark - request delegate
-(void)requestStarted:(ASIHTTPRequest *)request{
    [self performSelectorOnMainThread:@selector(setImage:) withObject:self.defaultImage waitUntilDone:NO];
    [self.delegate imageDidStartLoading:self];
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    NSLog(@"image url loading failed: %@", request.url);
    [self.delegate imageDidFailLoading:self];
}

-(void)requestFinished:(ASIHTTPRequest *)request{
    NSLog(@"image url loading completed: %@", request.url);
    UIImage* image = [UIImage imageWithData:request.responseData];
    image = [JJThumbnailCache storeThumbnail:image forURL:self.imageURL size:self.bounds.size];
    [self changeToLoadedImage:image];
    [self.delegate imageDidFinishLoading:self];
}
@end
