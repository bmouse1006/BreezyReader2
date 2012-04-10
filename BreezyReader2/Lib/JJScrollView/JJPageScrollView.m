//
//  JJImageScroll.m
//  MeetingPlatform
//
//  Created by  on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJImageScrollView.h"

CGPoint CGCenterOfRect(CGRect rect);

CGPoint CGCenterOfRect(CGRect rect){
    return CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2);
};

@interface JJImageScrollView (){
    NSInteger _pageCount;
    NSInteger _currentPageNumber;
}

-(void)loadPageAtIndex:(NSInteger)index;
-(void)removeInvisiblePageFaraway;
-(CGPoint)pageOffsetAtIndex:(NSInteger)index;
-(NSInteger)indexForOffset:(CGPoint)offset;

-(void)createContents;

-(UIView*)currentPage;

@property (nonatomic, retain) NSMutableDictionary* loadedPages;
@property (nonatomic, retain) NSMutableDictionary* invisiblePages;
@property (nonatomic, retain) NSMutableDictionary* pageFrames;

@end

@implementation JJImageScrollView

@synthesize imageScrollDelegate = _imageScrollDelegate, datasource = _datasource;
@synthesize pageIndex = pageIndex;
@synthesize loadedPages = _loadedPages, invisiblePages = _invisiblePages;
@synthesize pageFrames = _pageFrames;

-(void)dealloc{
    self.loadedPages = nil;
    self.invisiblePages = nil;
    self.pageFrames = nil;
    [super dealloc];
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.pagingEnabled = YES;
        self.bounces = YES;
        self.backgroundColor = [UIColor blackColor];
        self.maximumZoomScale = 4.0;
        self.delegate = self;
        self.pageIndex = 0;
        _pageCount = 0;
        self.loadedPages = [NSMutableDictionary dictionary];
        self.invisiblePages = [NSMutableDictionary dictionary];
        self.pageFrames = [NSMutableDictionary dictionary];
        UITapGestureRecognizer* doubleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)] autorelease];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
    }
    
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

-(void)reloadData{
    [[self.loadedPages allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.loadedPages removeAllObjects];    
    [self.pageFrames removeAllObjects];
    [self removeInvisiblePageFaraway];
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

-(void)removeInvisiblePageFaraway{
    [[self.invisiblePages allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.invisiblePages removeAllObjects];
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
    [self.imageScrollDelegate scrollView:self didScrollToPageAtIndex:index];
}

-(CGPoint)pageOffsetAtIndex:(NSInteger)index{
    NSNumber* pageKey = [NSNumber numberWithInt:index];
    CGRect frame = [[self.pageFrames objectForKey:pageKey] CGRectValue];
    CGPoint offset = CGPointMake(frame.origin.x, frame.origin.y+(frame.size.height-self.frame.size.height)/2);
    return offset;
}

-(id)dequeueReusableContentView{
    id view = nil;
    id key = [[self.invisiblePages allKeys] lastObject];
    if (key != nil){
        view = [[[self.invisiblePages objectForKey:key] retain] autorelease];
        [self.invisiblePages removeObjectForKey:key];
    }
    return view;
}

-(NSInteger)indexForOffset:(CGPoint)offset{
    return (int)(offset.x/self.bounds.size.width);
}

-(UIView*)currentPage{
    return [self.loadedPages objectForKey:[NSNumber numberWithInt:[self indexForOffset:self.contentOffset]]];
}

#pragma mark - scroll view delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //load more 
    [self.imageScrollDelegate scrollViewWillBeginDragging:self];
    NSInteger index = [self indexForOffset:self.contentOffset];
    [self loadPageAtIndex:index];
    [self loadPageAtIndex:index-1];
    [self loadPageAtIndex:index+1];
}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
////    NSInteger index = [self indexForOffset:self.contentOffset];
////    self.pageIndex = index;
////    [self.imageScrollDelegate scrollView:self didScrollToPageAtIndex:index];
//}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSInteger index = [self indexForOffset:self.contentOffset];
    self.pageIndex = index;
    [self.imageScrollDelegate scrollView:self didScrollToPageAtIndex:index];    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = [self indexForOffset:self.contentOffset];
    self.pageIndex = index;
    [self.imageScrollDelegate scrollView:self didScrollToPageAtIndex:index];  
}

#pragma mark - gesture recognizer action
-(void)doubleTapAction:(UITapGestureRecognizer*)gesture{
    UIView* page = [self currentPage];
    if([page respondsToSelector:@selector(doubleTapAction:)]){
        [page performSelector:@selector(doubleTapAction:) withObject:gesture];
    }
}

@end
