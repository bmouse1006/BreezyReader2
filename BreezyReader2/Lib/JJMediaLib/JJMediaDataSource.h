//
//  JJMediaDataSource.h
//  BreezyReader2
//
//  Created by  on 12-2-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol JJMediaLibTableViewCellDelegate, JJMediaSource;

@interface JJMediaDataSource : NSObject<UITableViewDataSource>

@property (nonatomic, assign) id<JJMediaLibTableViewCellDelegate> delegate;

-(id)initWithMediaSource:(id<JJMediaSource>)mediaSource delegate:(id<JJMediaLibTableViewCellDelegate>)delegate;
-(void)setThumbSize:(CGFloat)thumbSize thumbSpacing:(CGFloat)thumbSpacing;
-(Class)classForThumbnail;

@end
