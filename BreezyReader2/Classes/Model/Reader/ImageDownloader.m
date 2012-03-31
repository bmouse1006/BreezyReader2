//
//  ImageDownloader.m
//  BreezyReader
//
//  Created by Jin Jin on 10-7-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImageDownloader.h"


@implementation ImageDownloader

@synthesize imageURL = _imageURL;
@synthesize connection = _connection;
@synthesize delegate = _delegate;
@synthesize cachedData = _cachedData;

-(void)cancel{
	[self.connection cancel];
	self.delegate = nil;
}

-(void)startSync:(BOOL)sync{
	if (!sync) {
		[self performSelector:@selector(startDownload) 
					 onThread:[NSThread mainThread] 
				   withObject:nil 
				waitUntilDone:NO];
	}else {
		[self downloadSync];
	}

}

#pragma mark delegate method

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	DebugLog(@"error happened while loading: %@", self.imageURL);
	[self.delegate failedDownloadingImageForURL:self.imageURL];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	DebugLog(@"data received for image: %@", self.imageURL);
	[self.cachedData appendData:data]; 
	DebugLog(@"data appended");
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	DebugLog(@"did receive respone while loading: %@", self.imageURL);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	DebugLog(@"finished now:%@", self.imageURL);
	[self.delegate finishedDownloadingImageData:self.cachedData forURL:self.imageURL];
}

-(id)initWithImageURL:(NSString*)URL delegate:(NSObject<ImageDownloaderDelegate>*)mDelegate startNow:(BOOL)start{
	if (self = [super init]){
		self.delegate = mDelegate;
		self.imageURL = URL;
		self.cachedData = [NSMutableData data];
		if (start){
			[self startSync:NO];
		}
	}
	
	return self;
}

-(void)dealloc{
    self.delegate = nil;
    self.cachedData = nil;
    self.connection = nil;
    self.imageURL = nil;
    
	[super dealloc];
}

@end

@implementation ImageDownloader (private)

-(void)startDownload{
//	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	DebugLog(@"started downloading image:%@", self.imageURL);
	NSURL* url = [NSURL URLWithString:self.imageURL];
	NSURLRequest* request = [NSURLRequest requestWithURL:url 
											 cachePolicy:NSURLRequestReturnCacheDataElseLoad 
										 timeoutInterval:20];
	self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
//	[pool release];
}

-(void)downloadSync{
	NSURL* url = [NSURL URLWithString:self.imageURL];
	NSData* rowData = [NSData dataWithContentsOfURL:url];
	[self.delegate finishedDownloadingImageData:rowData forURL:self.imageURL];
}

@end

