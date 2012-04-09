//
//  JJMediaLibTableViewCell.h
//  BreezyReader2
//
//  Created by  on 12-2-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JJMediaLibTableViewCell;
@protocol JJMedia, JJMediaSource;

@protocol JJMediaLibTableViewCellDelegate <NSObject>

- (void)mediaLibTableViewCell:(JJMediaLibTableViewCell*)cell didSelectMediaAtIndex:(NSInteger)index; 

@end

@interface JJMediaLibTableViewCell : UITableViewCell

@property (nonatomic, retain) NSMutableArray* thumbnailViews;
@property (nonatomic, assign) id<JJMediaLibTableViewCellDelegate> delegate;

-(void)setColumnCount:(NSUInteger)columnCount;
-(void)setMediaSource:(id<JJMediaSource>)source withStartIndex:(NSUInteger)index;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier thumbSpacing:(CGFloat)thumbSpacing thumbSize:(CGFloat)thumbSize;

-(UIView*)thumbViewAtIndex:(NSInteger)index;
-(void)setThumbnailClass:(Class)thumbClass;

-(NSInteger)startIndex;

-(void)willDisappear:(BOOL)animated;
-(void)didDisappear:(BOOL)animated;
-(void)willAppear:(BOOL)animated;
-(void)didAppear:(BOOL)animated;

@end
