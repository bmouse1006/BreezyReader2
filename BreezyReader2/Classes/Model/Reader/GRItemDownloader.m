//
//  GRItemDownloader.m
//  BreezyReader
//
//  Created by Jin Jin on 10-7-29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GRItemDownloader.h"
#import "GRObjectsManager.h"
#import "GRItemModel.h"

@implementation GRItemDownloader

@synthesize item = _item;
@synthesize imageList = _imageList;
@synthesize downloaderPool = _downloaderPool;

@synthesize cancelled;
@synthesize delegate;
@synthesize context = _context;

-(void)cancel{
	self.cancelled = YES;
	//cancel all image downloader
	NSDictionary* dictionary = [[NSDictionary alloc] initWithDictionary:self.downloaderPool copyItems:NO];	
	
	NSEnumerator* enumerator = [dictionary objectEnumerator];
	
	ImageDownloader* downloader = nil;
	
	while (downloader = [enumerator nextObject]){
		[downloader cancel];
	}
	
	[dictionary release];
}

-(void)start{
	self.imageList = [self.item imageURLList];
	
	for (NSString* urlString in self.imageList){
		ImageDownloader* imageDownloader = [[ImageDownloader alloc] initWithImageURL:urlString 
																			delegate:self
																			startNow:NO];
		if (![self.downloaderPool objectForKey:urlString]){
			[self.downloaderPool setObject:imageDownloader forKey:urlString];
		}
		[imageDownloader release];
	}
	
	//the pool might be modified while interate, so we need to copy a new dictionary
	NSDictionary* dictionary = [[NSDictionary alloc] initWithDictionary:self.downloaderPool copyItems:NO];	
	
	NSEnumerator* enumerator = [dictionary objectEnumerator];

	ImageDownloader* downloader = nil;
	
	while (downloader = [enumerator nextObject]){
		[downloader startSync:NO];
		//if current thread is cancelled, break
		if ([[NSThread currentThread] isCancelled]){
			break;
		}
	}
	
	[dictionary release];
	[self checkIfAllImageDownloaderFinished];
}

#pragma mark delegate methods

-(void)finishedDownloadingImage:(UIImage*)image forURL:(NSString*)URL{
//	//save image to file
//	//combine md5 of item ID and URL of image as file name
//	DebugLog(@"finished downloading image:%@", URL);
//	[self saveImage:image forURL:URL];
//	@synchronized(_downloaderPool){
//		[self.downloaderPool removeObjectForKey:URL];
//	}
//	[self checkIfAllImageDownloaderFinished];
}

-(void)finishedDownloadingImageData:(NSData*)imageData forURL:(NSString*)URL{
	//save image to file
	//combine md5 of item ID and URL of image as file name
	DebugLog(@"finished downloading image:%@", URL);
	[self saveImageData:imageData forURL:URL];
	@synchronized(_downloaderPool){
		[self.downloaderPool removeObjectForKey:URL];
	}
	[self checkIfAllImageDownloaderFinished];
}

-(void)failedDownloadingImageForURL:(NSString*)URL{
	@synchronized(_downloaderPool){
		[self.downloaderPool removeObjectForKey:URL];
	}
	[self checkIfAllImageDownloaderFinished];
}

-(id)initWithGRItem:(GRItem*)mItem 
		   delegate:(NSObject<GRItemDownloaderDelegate>*)mDelegate 
		   startNow:(BOOL)start 
			context:(NSManagedObjectContext*)mContext{
	if (self = [super init]){
		self.item = mItem;
		self.cancelled = NO;
		self.delegate = mDelegate;
		self.downloaderPool = [NSMutableDictionary dictionary];
		self.context = mContext;
		if (start){
			[self start];
		}
	}
	
	return self;
}

-(void)dealloc{
    self.delegate = nil;
    self.item = nil;
    self.imageList = nil;
    self.downloaderPool = nil;
    self.context = nil;
	[super dealloc];
}

@end

@implementation GRItemDownloader (private)

-(void)saveImageData:(NSData*)imageData forURL:(NSString*)urlString{
	
	NSString* filePath = [self.item filePathForImageURLString:urlString];
	
	NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:imageData, @"rowData", filePath, @"filePath", nil];
	
    [self performSelectorInBackground:@selector(taskSaveImage:) withObject:parameters];
}

-(void)taskSaveImage:(NSDictionary*)parameters{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSData* rowData = [parameters objectForKey:@"rowData"];
	NSString* filePath = [parameters objectForKey:@"filePath"];
	
	UIImage* image = [UIImage imageWithData:rowData];
	NSData* encryptData = UIImageJPEGRepresentation(image, 1);

	[encryptData writeToFile:filePath atomically:YES];
	
	[pool release];
}

-(void)checkIfAllImageDownloaderFinished{
	if ([[NSThread currentThread] isCancelled]){
		[self cancel];
		[self.delegate failedDownloadingGRItem:self.item];
	}else{
		@synchronized(_downloaderPool){
			if (![self.downloaderPool count]){//no downloader anymore, means all image downloading are finished
				[self saveGRItem:self.item];
				[self.delegate finishedDownloadingGRItem:self.item];
			}
		}
	}
}

-(BOOL)saveGRItem:(GRItem*)item{
	
	GRItemModel* itemModel = (GRItemModel*)[NSEntityDescription insertNewObjectForEntityForName:@"GRItemModel" 
																		 inManagedObjectContext:self.context];
	
	[itemModel setGRItem:item];
	itemModel.downloadedDate = [NSDate date];
	
	[GRObjectsManager insertObject:itemModel];
	
	return YES;
	
}

@end

