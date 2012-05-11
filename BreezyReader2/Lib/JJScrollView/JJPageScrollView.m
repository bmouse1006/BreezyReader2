 //
//  JJImageScroll.m
//  BreezyReader2
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJPageScrollView.h"

CGPoint CGCenterOfRect(CGRect rect);

inline CGPoint CGCenterOfRect(CGRect rect){
    return CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2);
};

@interface JJPageScrollView (){
    NSInteger _pageCount;
    NSInteger _currentPageNumber;
}

-(void)loadPageAtIndex:(NSInteger)index;
-(CGPoint)pageOffsetAtIndex:(NSInteger)index;
-(NSInteger)indexForOffset:(CGPoint)offset;
-(CGPoint)offsetOfTouch:(CGPoint)location;

-(void)createContents;

-(void)clearInvisiblePages;

@property (nonatomic, retain) NSMutableDictionary* loadedPages;
@property (nonatomic, retain) NSMutableDictionary* pageFrames;

@property (nonatomic, retain) UIScrollView* scrollView;
@property (nonatomic, retain) UIPageControl* pageControl;

@end

@implementation JJPageScrollView

@synthesize delegate = _delegate, datasource = _datasource;
@synthesize pageIndex = _pageIndex;
@synthesize loadedPages = _loadedPages;
@synthesize pageFrames = _pageFrames;
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize showPageControl = _showPageControl;
@synthesize pageControlVerticalAlignment = _pageControlVerticalAlignment;
@synthesize pageControlHorizonAlignment = _pageControlHorizonAlignment;

-(void)dealloc{
    self.loadedPages = nil;
    self.pageFrames = nil;
    self.scrollView = nil;
    self.pageControl = nil;
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
    
    self.scrollView = [[[UIScrollView alloc] initWithFrame:self.bounds] autorelease];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = YES;
    [self addSubview:self.scrollView];
    
    self.pageControl = [[[UIPageControl alloc] initWithFrame:CGRectZero] autorelease];
    self.pageControl.hidesForSinglePage = YES;
    [self addSubview:self.pageControl];
    
    self.showPageControl = NO;
    
    self.backgroundColor = [UIColor blackColor];
    self.pageIndex = 0;
    _pageCount = 0;
    self.loadedPages = [NSMutableDictionary dictionary];
    self.pageFrames = [NSMutableDictionary dictionary];
    
    self.pageControlHorizonAlignment = JJHorizonAlignmentMiddle;
    self.pageControlVerticalAlignment = JJVerticalAlignmentBottom;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    self.pageControl.numberOfPages = [self.datasource numberOfPagesInScrollView:self];
    self.pageControl.currentPage = [self currentIndex];

    CGSize size = [self.pageControl sizeForNumberOfPages:self.pageControl.numberOfPages];
    CGRect frame = self.pageControl.frame;
    frame.size.width = size.width;
    frame.size.height = size.height;
    switch (self.pageControlHorizonAlignment) {
        case JJHorizonAlignmentLeft:
            frame.origin.x = 0 + 5;
            break;
        case JJHorizonAlignmentRight:
            frame.origin.x = self.bounds.size.width - frame.size.width - 5;
            break;
        case JJHorizonAlignmentMiddle:
            frame.origin.x = (self.bounds.size.width - frame.size.width)/2;
            break;
        default:
            break;
    }
    
    switch (self.pageControlVerticalAlignment) {
        case JJVerticalAlignmentTop:
            frame.origin.y = 0 - 5;
            break;
        case JJVerticalAlignmentBottom:
            frame.origin.y = self.bounds.size.height - frame.size.height+5;
            break;
        case JJVerticalAlignmentCenter:
            frame.origin.y = (self.bounds.size.height - frame.size.height)/2;
            break;
        default:
            break;
    }
    
    self.pageControl.frame = frame;
    self.pageControl.hidden = !self.showPageControl;
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
    
    [self.scrollView setContentSize:contentSize];
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
    [self.scrollView addSubview:page];
}

-(void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated{
    index = (index % _pageCount);
//    if (index < 0){
//        index = 0;
//    }
//    if (index >= _pageCount){
//        index = _pageCount-1;
//    }
    
    [self loadPageAtIndex:index];
    [self loadPageAtIndex:index-1];
    [self loadPageAtIndex:index+1];
    [self.scrollView setContentOffset:[self pageOffsetAtIndex:index] animated:animated];
    self.pageIndex = index;
    if ([self.delegate respondsToSelector:@selector(scrollView:didScrollToPageAtIndex:)]){
        [self.delegate scrollView:self didScrollToPageAtIndex:index];
    }
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
    return [self pageAtIndex:[self indexForOffset:self.scrollView.contentOffset]];
}

-(UIView*)pageAtIndex:(NSInteger)index{
    return [self.loadedPages objectForKey:[NSNumber numberWithInt:index]];
}

#pragma mark - scroll view delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //load more 
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]){
        [self.delegate scrollViewWillBeginDragging:self];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate == YES){
        self.userInteractionEnabled = NO;
    }else{
        self.userInteractionEnabled = YES;
        NSInteger index = [self currentIndex];
        self.pageIndex = index; 
        [self loadPage];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.userInteractionEnabled = YES;
    NSInteger index = [self currentIndex];
    self.pageIndex = index;
    [self loadPage];
}

-(void)loadPage{
    NSInteger index = [self currentIndex];
    self.pageIndex = index;  
    [self loadPageAtIndex:index-1];
    [self loadPageAtIndex:index+1];
    [self clearInvisiblePages];
}

-(void)clearInvisiblePages{
    NSInteger index = [self currentIndex];
    for (NSNumber* key in [self.loadedPages allKeys]){
        if ([key intValue]>index + 1 || [key intValue] < index - 1){
            [self removePageWithIndex:[key intValue]];
        }
    }
}

-(NSInteger)currentIndex{
    return [self indexForOffset:self.scrollView.contentOffset];
}

-(void)removePageWithIndex:(NSInteger)index{
    NSNumber* key = [NSNumber numberWithInt:index];
    UIView* page = [self.loadedPages objectForKey:key];
    [page removeFromSuperview];
    [self.loadedPages removeObjectForKey:key];
    if ([self.delegate respondsToSelector:@selector(scrollViewDidRemovePageAtIndex:)]){
        [self.delegate scrollViewDidRemovePageAtIndex:index];
    }
}

-(CGPoint)offsetOfTouch:(CGPoint)location{
    CGPoint offset = self.scrollView.contentOffset;
    offset.x += location.x;
    return offset;
}

#pragma mark - getter setter

-(void)setShowPageControl:(BOOL)showPageControl{
    _showPageControl = showPageControl;
    [self setNeedsLayout];
}

-(void)setPageControlVerticalAlignment:(JJVerticalAlignment)pageControlVerticalAlignment{
    _pageControlVerticalAlignment = pageControlVerticalAlignment;
    [self setNeedsLayout];
}

-(void)setPageControlHorizonAlignment:(JJHorizonAlignment)pageControlHorizonAlignment{
    _pageControlHorizonAlignment = pageControlHorizonAlignment;
    [self setNeedsLayout];
}

-(void)setPageIndex:(NSUInteger)pageIndex{
    _pageIndex = pageIndex;
    self.pageControl.currentPage = pageIndex;
    if ([self.delegate respondsToSelector:@selector(scrollView:didScrollToPageAtIndex:)]){
        [self.delegate scrollView:self didScrollToPageAtIndex:pageIndex];
    }
}

@end
