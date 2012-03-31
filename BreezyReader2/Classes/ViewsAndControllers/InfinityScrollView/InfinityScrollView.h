//
//  InfinityScrollView.h
//  BreezyReader2
//
//  Created by 金 津 on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    InfinityScrollViewDirectionLeft = 1,
    InfinityScrollViewDirectionRight
} InfinityScrollViewDirection;

@class InfinityScrollView;

@protocol InfinityScrollViewDelegate <NSObject>

-(void)scrollViewDidScroll:(InfinityScrollView*)scrollView;

-(void)scrollView:(InfinityScrollView*)scrollView didStopAtChildViewOfIndex:(NSInteger)index;

-(void)scrollView:(InfinityScrollView*)scrollView userDraggingOffset:(CGPoint)offset;

@end

@protocol InfinityScrollViewDataSource

-(NSInteger)numberOfContentViewsInScrollView:(InfinityScrollView*)scrollView;
-(UIView*)scrollView:(InfinityScrollView*)scrollView contentViewAtIndex:(NSInteger)index;
-(void)reload;

@end

@interface InfinityScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, assign) IBOutlet id<InfinityScrollViewDataSource> dataSource;
@property (nonatomic, assign) IBOutlet id<InfinityScrollViewDelegate> infinityDelegate;

-(void)reloadData;
-(void)moveToChildViewAtIndex:(NSInteger)index direction:(InfinityScrollViewDirection)direction animated:(BOOL)animated;

@end
