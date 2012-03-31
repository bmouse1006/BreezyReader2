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

@property (nonatomic, retain) NSString* imageURL;
@property (nonatomic, retain) NSURLConnection* connection;
@property (nonatomic, retain) NSMutableData* cachedData;
@property (nonatomic, retain) NSObject<ImageDownloaderDelegate>* delegate;

-(id)initWithImageURL:(NSString*)URL delegate:(NSObject<ImageDownloaderDelegate>*)mDelegate startNow:(BOOL)start;
-(void)cancel;
-(void)startSync:(BOOL)sync;

@end

@interface ImageDownloader (private)

-(void)startDownload;
-(void)downloadSync;

@end



