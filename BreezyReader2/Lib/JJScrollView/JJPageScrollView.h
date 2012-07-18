//
//  JJImageScroll.h
//  BreezyReader2
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JJPageScrollView;

typedef enum{
    JJVerticalAlignmentTop,
    JJVerticalAlignmentCenter,
    JJVerticalAlignmentBottom
} JJVerticalAlignment;

typedef enum{
    JJHorizonAlignmentLeft,
    JJHorizonAlignmentMiddle,
    JJHorizonAlignmentRight
} JJHorizonAlignment;

@protocol JJPageScrollViewDataSource <NSObject>

-(NSUInteger)numberOfPagesInScrollView:(JJPageScrollView*)scrollView;
-(UIView*)scrollView:(JJPageScrollView*)scrollView pageAtIndex:(NSInteger)index;
-(CGSize)scrollView:(JJPageScrollView*)scrollView sizeOfPageAtIndex:(NSInteger)index;

@end

@protocol JJPageScrollViewDelegate <NSObject>

@optional
-(void)scrollViewDidRemovePageAtIndex:(NSInteger)index;
-(void)scrollView:(JJPageScrollView*)scrollView didScrollToPageAtIndex:(NSInteger)index;
-(void)scrollViewWillStartDragging:(JJPageScrollView *)scrollView;

@end

@interface JJPageScrollView : UIView<UIScrollViewDelegate>

@property (nonatomic, unsafe_unretained) IBOutlet id<JJPageScrollViewDataSource> datasource;
@property (nonatomic, unsafe_unretained) IBOutlet id<JJPageScrollViewDelegate> delegate;

@property (nonatomic, assign) NSUInteger pageIndex;

@property (nonatomic, assign) BOOL showPageControl;

@property (nonatomic, assign) JJHorizonAlignment pageControlHorizonAlignment;
@property (nonatomic, assign) JJVerticalAlignment pageControlVerticalAlignment;

-(void)reloadData;

-(void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated;
-(NSInteger)currentIndex;
-(UIView*)currentPage;
-(UIView*)pageAtIndex:(NSInteger)index;

@end
