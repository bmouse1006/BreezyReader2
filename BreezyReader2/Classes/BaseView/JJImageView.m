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

-(ASIHTTPRequest*)requestWithURL:(NSURL*)url;

@end

@implementation JJImageView

@synthesize defaultImage = _defaultImage, imageURL = _imageURL;
@synthesize request = _request;
@synthesize delegate = _delegate;


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
                    [blockSelf performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
                    [blockSelf.delegate imageDidFinishLoading:blockSelf];
                }else{
                    [blockSelf performSelectorOnMainThread:@selector(setImage:) withObject:blockSelf.defaultImage waitUntilDone:NO];
                    blockSelf.request = [blockSelf requestWithURL:imageURL];
                    [blockSelf.request startAsynchronous];
                } 
            });
        }else{
            [self performSelectorOnMainThread:@selector(setImage:) withObject:self.defaultImage waitUntilDone:NO];
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
    [self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
    [self.delegate imageDidFinishLoading:self];
}
@end
