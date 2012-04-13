//
//  JJImageScroll.h
//  BreezyReader2
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JJPageScrollView;

@protocol JJPageScrollViewDataSource <NSObject>

-(NSUInteger)numberOfPagesInScrollView:(JJPageScrollView*)scrollView;
-(UIView*)scrollView:(JJPageScrollView*)scrollView pageAtIndex:(NSInteger)index;
-(CGSize)scrollView:(JJPageScrollView*)scrollView sizeOfPageAtIndex:(NSInteger)index;

@end

@protocol JJPageScrollViewDelegate <NSObject>

-(void)scrollView:(JJPageScrollView*)scrollView didScrollToPageAtIndex:(NSInteger)index;
-(void)scrollViewWillBeginDragging:(JJPageScrollView *)scrollView;

@optional
-(void)scrollViewDidRemovePageAtIndex:(NSInteger)index;

@end

@interface JJPageScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, assign) id<JJPageScrollViewDataSource> datasource;
@property (nonatomic, assign) id<JJPageScrollViewDelegate> scrollDelegate;

@property (nonatomic, assign) NSUInteger pageIndex;

-(void)reloadData;

-(void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated;
-(NSInteger)currentIndex;
-(UIView*)currentPage;
-(UIView*)pageAtIndex:(NSInteger)index;

@end
