 //
//  JJImageScroll.m
//  MeetingPlatform
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJPageScrollView.h"

CGPoint CGCenterOfRect(CGRect rect);

CGPoint CGCenterOfRect(CGRect rect){
    return CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2);
};

@interface JJPageScrollView (){
    NSInteger _pageCount;
    NSInteger _currentPageNumber;
}

-(void)loadPageAtIndex:(NSInteger)index;
-(CGPoint)pageOffsetAtIndex:(NSInteger)index;
-(NSInteger)indexForOffset:(CGPoint)offset;

-(void)createContents;

-(void)clearInvisiblePages;

@property (nonatomic, retain) NSMutableDictionary* loadedPages;
@property (nonatomic, retain) NSMutableDictionary* pageFrames;

@end

@implementation JJPageScrollView

@synthesize scrollDelegate = _scrollDelegate, datasource = _datasource;
@synthesize pageIndex = pageIndex;
@synthesize loadedPages = _loadedPages;
@synthesize pageFrames = _pageFrames;

-(void)dealloc{
    self.loadedPages = nil;
    self.pageFrames = nil;
    [super dealloc];
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self createViews];
    }
    
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self createViews];
}

-(void)createViews{
    self.pagingEnabled = YES;
    self.bounces = YES;
    self.backgroundColor = [UIColor blackColor];
    self.delegate = self;
    self.pageIndex = 0;
    _pageCount = 0;
    self.loadedPages = [NSMutableDictionary dictionary];
    self.pageFrames = [NSMutableDictionary dictionary];
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

-(void)reloadData{
    [[self.loadedPages allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.loadedPages removeAllObjects];    
    [self.pageFrames removeAllObjects];
    _pageCount = [self.datasource numberOfPagesInScrollView:self];
    [self createContents];
    [self setNeedsLayout];
}

-(void)createContents{
    //caculate content size
    CGSize contentSize = CGSizeMake(0, self.frame.size.height);
    CGPoint preOrigin = CGPointMake(-self.bounds.size.width, 0);
    for (int i = 0; i< _pageCount; i++){
        CGSize size = [self.datasource scrollView:self sizeOfPageAtIndex:i];
        if (size.width >= self.bounds.size.width){
            contentSize.width += size.width;
        }else{
            contentSize.width += self.bounds.size.width;
        }
        CGPoint newOrigin = CGPointMake(preOrigin.x + self.bounds.size.width, 0);
        CGRect frame = CGRectMake(newOrigin.x, newOrigin.y, size.width, size.height);
        [self.pageFrames setObject:[NSValue valueWithCGRect:frame] forKey:[NSNumber numberWithInt:i]];
        preOrigin = newOrigin;
    }
    
    [self setContentSize:contentSize];
    [self scrollToPageAtIndex:self.pageIndex animated:NO];
}

-(void)loadPageAtIndex:(NSInteger)index{
    if (index < 0 || index >= _pageCount){
        return;
    }
    
    NSNumber* pageKey = [NSNumber numberWithInt:index];
    if ([self.loadedPages objectForKey:pageKey]){
        return;
    }
    
    UIView* page = [self.datasource scrollView:self pageAtIndex:index];
    [self.loadedPages setObject:page forKey:pageKey];
    
    CGRect frame = [[self.pageFrames objectForKey:pageKey] CGRectValue];
    [page setFrame:frame];
    [self addSubview:page];
}

-(void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated{
    if (index < 0){
        index = 0;
    }
    if (index >= _pageCount){
        index = _pageCount-1;
    }
    
    [self loadPageAtIndex:index];
    [self loadPageAtIndex:index-1];
    [self loadPageAtIndex:index+1];
    [self setContentOffset:[self pageOffsetAtIndex:index] animated:animated];
    self.pageIndex = index;
    [self.scrollDelegate scrollView:self didScrollToPageAtIndex:index];
}

-(CGPoint)pageOffsetAtIndex:(NSInteger)index{
    NSNumber* pageKey = [NSNumber numberWithInt:index];
    CGRect frame = [[self.pageFrames objectForKey:pageKey] CGRectValue];
    CGPoint offset = CGPointMake(frame.origin.x, frame.origin.y+(frame.size.height-self.frame.size.height)/2);
    return offset;
}

-(NSInteger)indexForOffset:(CGPoint)offset{
    return (int)(offset.x/self.bounds.size.width);
}

-(UIView*)currentPage{
    return [self pageAtIndex:[self indexForOffset:self.contentOffset]];
}

-(UIView*)pageAtIndex:(NSInteger)index{
    return [self.loadedPages objectForKey:[NSNumber numberWithInt:index]];
}

#pragma mark - scroll view delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //load more 
    [self.scrollDelegate scrollViewWillBeginDragging:self];
    NSInteger index = [self currentIndex];
    [self loadPageAtIndex:index];
    [self loadPageAtIndex:index-1];
    [self loadPageAtIndex:index-2];
    [self loadPageAtIndex:index+1];
    [self loadPageAtIndex:index+2];
    [self clearInvisiblePages];
}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
////    NSInteger index = [self indexForOffset:self.contentOffset];
////    self.pageIndex = index;
////    [self.scrollDelegate scrollView:self didScrollToPageAtIndex:index];
//}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSInteger index = [self currentIndex];
    self.pageIndex = index;
    [self.scrollDelegate scrollView:self didScrollToPageAtIndex:index];  
    [self loadPageAtIndex:index-1];
    [self loadPageAtIndex:index-2];
    [self loadPageAtIndex:index+1];
    [self loadPageAtIndex:index+2];
    [self clearInvisiblePages];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = [self currentIndex];
    self.pageIndex = index;
    [self.scrollDelegate scrollView:self didScrollToPageAtIndex:index];  
    [self loadPageAtIndex:index-1];
    [self loadPageAtIndex:index-2];
    [self loadPageAtIndex:index+1];
    [self loadPageAtIndex:index+2];
    [self clearInvisiblePages];
}

-(void)clearInvisiblePages{
    NSInteger index = [self currentIndex];
    for (NSNumber* key in [self.loadedPages allKeys]){
        if ([key intValue]>index + 2 || [key intValue] < index - 2){
            [self removePageWithIndex:[key intValue]];
        }
    }
}

-(NSInteger)currentIndex{
    return [self indexForOffset:self.contentOffset];
}

-(void)removePageWithIndex:(NSInteger)index{
    NSNumber* key = [NSNumber numberWithInt:index];
    UIView* page = [self.loadedPages objectForKey:key];
    [page removeFromSuperview];
    [self.loadedPages removeObjectForKey:key];
    if ([self.scrollDelegate respondsToSelector:@selector(scrollViewDidRemovePageAtIndex:)]){
        [self.scrollDelegate scrollViewDidRemovePageAtIndex:index];
    }
}

@end
