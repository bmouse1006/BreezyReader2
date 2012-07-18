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

@property (nonatomic, strong) NSNumber * readed;
@property (nonatomic, strong) NSString * selfLink;
@property (nonatomic, strong) NSString * author;
@property (nonatomic, strong) NSString * alternateLink;
@property (nonatomic, strong) NSDate * published;
@property (nonatomic, strong) NSString * ID;
@property (nonatomic, strong) NSString * source_alternateLink;
@property (nonatomic, strong) NSString * source;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSNumber * starred;
@property (nonatomic, strong) NSString * summary;
@property (nonatomic, strong) NSString * source_title;
@property (nonatomic, strong) NSNumber * newAttribute;
@property (nonatomic, strong) NSString * source_selfLink;
@property (nonatomic, strong) NSString * source_ID;
@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSDate * updated;
@property (nonatomic, strong) NSDate * downloadedDate;

-(void)setGRItem:(GRItem*)item;
-(GRItem*)GRItem;
-(void)removeDownloadedImages;

@end



