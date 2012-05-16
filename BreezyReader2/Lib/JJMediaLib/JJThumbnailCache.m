//
//  JJThumbnailCache.m
//  BreezyReader2
//
//  Created by  on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJThumbnailCache.h"
#import "NSString+MD5.h"
#import "UIImage+clip.h"

@interface JJThumbnailCache(){
    NSMutableDictionary* _imgCache;
}

+(id)sharedCache;

-(NSString*)cachePath;
-(UIImage*)cachedImageInMemoryForURL:(NSURL*)url;
-(UIImage*)cachedImageInMemoryForURL:(NSURL*)url andSize:(CGSize)size;
-(void)saveImage:(UIImage*)image toMemoryCacheForURL:(NSURL*)url;
-(void)saveImage:(UIImage*)image toMemoryCacheForURL:(NSURL*)url andSize:(CGSize)size;

@end

@implementation JJThumbnailCache

static JJThumbnailCache* _cache = nil;
static NSString* _cachePath = nil;

-(id)init{
    self = [super init];
    if (self){
        _imgCache = [[NSMutableDictionary dictionary] retain];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMemroyWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    
    return self;
}

-(void)dealloc{
    [_imgCache release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

-(void)receivedMemroyWarning:(NSNotification*)notification{
    [_imgCache removeAllObjects];
}

-(NSString*)cachePath{
    if (_cachePath == nil){
        _cachePath = [[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"thumbnailClipCache"] retain];
        NSFileManager* fm = [NSFileManager defaultManager];
        BOOL isDictionary = NO;
        if ([fm fileExistsAtPath:_cachePath isDirectory:&isDictionary] == NO){
            [fm createDirectoryAtPath:_cachePath withIntermediateDirectories:NO attributes:nil error:NULL];
        }
    }
    
    return _cachePath;
}

+(UIImage*)storeThumbnail:(UIImage *)thumb forURL:(NSURL *)url size:(CGSize)size{
    NSString* filePath = [self filePathForStoredThumbnailOfURL:url andSize:size];
    UIImage* nail = [thumb clippedThumbnailWithSize:size];
    [UIImageJPEGRepresentation(nail, 0.6) writeToFile:filePath atomically:YES];
    [[self sharedCache] saveImage:nail toMemoryCacheForURL:url andSize:size];
    return nail;
}

+(NSString*)filePathForStoredThumbnailOfURL:(NSURL*)url{
    NSString* filename = [[[url absoluteString] MD5] stringByAppendingPathExtension:@"jpg"];
    return [[[self sharedCache] cachePath] stringByAppendingPathComponent:filename];
}

+(NSString*)filePathForStoredThumbnailOfURL:(NSURL*)url andSize:(CGSize)size{
    NSString* filename = [[[[url absoluteString] stringByAppendingString:NSStringFromCGSize(size)] MD5] stringByAppendingPathExtension:@"jpg"];
    return [[[self sharedCache] cachePath] stringByAppendingPathComponent:filename];
}

+(UIImage*)thumbnailForURL:(NSURL*)url{
    UIImage* image = [[self sharedCache] cachedImageInMemoryForURL:url];
    if (image == nil){
        image = [UIImage imageWithContentsOfFile:[self filePathForStoredThumbnailOfURL:url]];
        [[self sharedCache] saveImage:image toMemoryCacheForURL:url];
    }
    return image;
}

+(UIImage*)thumbnailForURL:(NSURL *)url andSize:(CGSize)size{
    UIImage* image = [[self sharedCache] cachedImageInMemoryForURL:url andSize:size];
    if (image == nil){
//        DebugLog(@"image: %@", [self filePathForStoredThumbnailOfURL:url andSize:size]);
        image = [UIImage imageWithContentsOfFile:[self filePathForStoredThumbnailOfURL:url andSize:size]];
        [[self sharedCache] saveImage:image toMemoryCacheForURL:url andSize:size];
    }
    return image;
}

+(id)sharedCache{
    if (_cache == nil){
        _cache = [[JJThumbnailCache alloc] init];
    }
    
    return _cache;
}

-(UIImage*)cachedImageInMemoryForURL:(NSURL*)url{
    return [_imgCache objectForKey:[[self class] filePathForStoredThumbnailOfURL:url]];
}

-(UIImage*)cachedImageInMemoryForURL:(NSURL*)url andSize:(CGSize)size{
    return [_imgCache objectForKey:[[self class] filePathForStoredThumbnailOfURL:url andSize:size]];
}

-(void)saveImage:(UIImage*)image toMemoryCacheForURL:(NSURL*)url{
    if (image != nil){
        [_imgCache setObject:image forKey:[[self class] filePathForStoredThumbnailOfURL:url]];
    }
}

-(void)saveImage:(UIImage*)image toMemoryCacheForURL:(NSURL*)url andSize:(CGSize)size{
    if (image != nil){
        [_imgCache setObject:image
                      forKey:[[self class] filePathForStoredThumbnailOfURL:url andSize:size]];
    }
}



@end
