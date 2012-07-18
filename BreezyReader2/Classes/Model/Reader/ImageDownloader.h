//
//  ImageDownloader.h
//  BreezyReader
//
//  Created by Jin Jin on 10-7-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageDownloaderDelegate

-(void)finishedDownloadingImage:(UIImage*)image forURL:(NSString*)URL;
-(void)finishedDownloadingImageData:(NSData*)imageData forURL:(NSString*)URL;
-(void)failedDownloadingImageForURL:(NSString*)URL;

@end

@interface ImageDownloader : NSObject 

@property (nonatomic, strong) NSString* imageURL;
@property (nonatomic, strong) NSURLConnection* connection;
@property (nonatomic, strong) NSMutableData* cachedData;
@property (nonatomic, strong) NSObject<ImageDownloaderDelegate>* delegate;

-(id)initWithImageURL:(NSString*)URL delegate:(NSObject<ImageDownloaderDelegate>*)mDelegate startNow:(BOOL)start;
-(void)cancel;
-(void)startSync:(BOOL)sync;

@end

@interface ImageDownloader (private)

-(void)startDownload;
-(void)downloadSync;

@end



