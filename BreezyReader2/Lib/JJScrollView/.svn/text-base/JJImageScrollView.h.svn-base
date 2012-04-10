//
//  JJImageScroll.h
//  MeetingPlatform
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JJImageScrollView;

@protocol JJImageScrollViewDataSource <NSObject>

-(id)objectAtIndex:(NSInteger)index;
-(NSUInteger)numberOfPagesInScrollView:(JJImageScrollView*)scrollView;
-(UIView*)scrollView:(JJImageScrollView*)scrollView pageAtIndex:(NSInteger)index;
-(CGSize)scrollView:(JJImageScrollView*)scrollView sizeOfPageAtIndex:(NSInteger)index;

@end

@protocol JJImageScrollViewDelegate <NSObject>

-(void)scrollView:(JJImageScrollView*)scrollView didScrollToPageAtIndex:(NSInteger)index;
-(void)scrollViewWillBeginDragging:(JJImageScrollView *)scrollView;

@end

@interface JJImageScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, assign) id<JJImageScrollViewDataSource> datasource;
@property (nonatomic, assign) id<JJImageScrollViewDelegate> imageScrollDelegate;

@property (nonatomic, assign) NSUInteger pageIndex;

-(void)reloadData;
-(void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated;

-(id)dequeueReusableContentView;

@end
