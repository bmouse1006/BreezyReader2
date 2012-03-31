//
//  GRItemModel.h
//  BreezyReader
//
//  Created by Jin Jin on 10-7-31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "GRItem.h"


@interface GRItemModel :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * readed;
@property (nonatomic, retain) NSString * selfLink;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * alternateLink;
@property (nonatomic, retain) NSDate * published;
@property (nonatomic, retain) NSString * ID;
@property (nonatomic, retain) NSString * source_alternateLink;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * starred;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * source_title;
@property (nonatomic, retain) NSNumber * newAttribute;
@property (nonatomic, retain) NSString * source_selfLink;
@property (nonatomic, retain) NSString * source_ID;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSDate * downloadedDate;

-(void)setGRItem:(GRItem*)item;
-(GRItem*)GRItem;
-(void)removeDownloadedImages;

@end



