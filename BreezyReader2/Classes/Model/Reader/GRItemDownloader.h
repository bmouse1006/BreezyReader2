//
//  GRItemDownloader.h
//  BreezyReader
//
//  Created by Jin Jin on 10-7-29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRObjectsManager.h"
#import "GRItem.h"
#import "ImageDownloader.h"

@protocol GRItemDownloaderDelegate
	
-(void)finishedDownloadingGRItem:(GRItem*)item;
-(void)failedDownloadingGRItem:(GRItem*)item;

@end

@interface GRItemDownloader : NSObject<ImageDownloaderDelegate>

@property (nonatomic, retain) GRItem* item;
@property (nonatomic, retain) NSArray* imageList;
@property (retain) NSMutableDictionary* downloaderPool;//need to consider multi thread access
@property (nonatomic, assign) BOOL cancelled;
@property (nonatomic, retain) NSObject<GRItemDownloaderDelegate>* delegate;

@property (nonatomic, retain) NSManagedObjectContext* context;

-(void)cancel;
-(void)start;

-(id)initWithGRItem:(GRItem*)mItem 
		   delegate:(NSObject<GRItemDownloaderDelegate>*)mDelegate 
		   startNow:(BOOL)start 
			context:(NSManagedObjectContext*)context;

@end

@interface GRItemDownloader (private)

-(void)saveImageData:(NSData*)imageData forURL:(NSString*)urlString;
-(void)taskSaveImage:(NSDictionary*)parameters;
-(void)checkIfAllImageDownloaderFinished;
-(BOOL)saveGRItem:(GRItem*)item;

@end