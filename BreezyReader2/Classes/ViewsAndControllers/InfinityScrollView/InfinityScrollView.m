//
//  InfinityScrollView.m
//  BreezyReader2
//
//  Created by 金 津 on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "InfinityScrollView.h"
#import "InfinityScrollContainer.h"

@interface InfinityScrollView() {
    NSInteger _count;
    NSInteger _index;
}

@property (nonatomic, retain) NSMutableSet* containers;
@property (nonatomic, assign) InfinityScrollContainer* middleContainer;

-(void)initialize;
-(void)generateAndSetupContainers;
-(void)rearrangeContainers:(CGPoint)translate;
-(void)translateContainers;

-(void)loadContentViewToContainer:(InfinityScrollContainer*)container;

-(NSInteger)indexOfSelectedChildView;

@end

@implementation InfinityScrollView

@synthesize dataSource = _dataSource;
@synthesize containers = _containers;
@synthesize middleContainer = _middleContainer;
@synthesize infinityDelegate = _infinityDelegate;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.bounces = NO;
        self.bouncesZoom = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = self;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = NO;
        self.pagingEnabled = YES;
        _index = 0;
    }
    
    return self;
}

-(void)dealloc{
    self.dataSource = nil;
    self.containers = nil;
    self.middleContainer = nil;
    [super dealloc];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.bounces = NO;
    self.bouncesZoom = NO;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.delegate = self;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.autoresizesSubviews = NO;
    self.pagingEnabled = YES;
}

-(void)setIndex:(NSInteger)index{
    _index = index;
}

-(void)initialize{
    //setup
    [self generateAndSetupContainers];
    CGRect frame = self.frame;
    CGFloat width = frame.size.width;
    self.contentSize = CGSizeMake(width * [self.containers count] , frame.size.height);
    self.contentOffset = CGPointMake(width, 0);
}

-(void)generateAndSetupContainers{
    self.containers = [NSMutableSet setWithCapacity:0];
    
    for (UIView* sub in [self subviews]){
        [sub removeFromSuperview];
    }
    
    _index = (_index > _count - 1)?_count-1:_index;
    NSInteger leftIndex = (_index - 1 < 0)?_count-1:_index-1;
    NSInteger rightIndex = (_index+1>_count-1)?0:_index+1;
    
    CGRect frame = self.bounds;
    frame.origin.x = 0;
    frame.origin.y = 0;
    InfinityScrollContainer* left = [[InfinityScrollContainer alloc] initWithContainerFrame:frame];
    InfinityScrollContainer* mid = [[InfinityScrollContainer alloc] initWithContainerFrame:frame];
    InfinityScrollContainer* right = [[InfinityScrollContainer alloc] initWithContainerFrame:frame];
    left.leftContainer = right;
    left.rightContainer = mid;
    left.index = leftIndex;
    mid.leftContainer = left;
    mid.rightContainer = right;
    mid.index = _index;
    right.leftContainer = mid;
    right.rightContainer = left;
    right.index = rightIndex;
    [self.containers addObject:left];
    [self.containers addObject:right];
    [self.containers addObject:mid];
    
    self.middleContainer = mid;
    
    [self translateContainers];
    
    if (_count <= 2){
        mid.rightContainer = left;
        left.leftContainer = mid;
        [self.containers removeObject:right];
    }
    if (_count > 0){
        InfinityScrollContainer* container = self.middleContainer;
        do {
            [self addSubview:container.view];
            [self loadContentViewToContainer:container];
            container = container.rightContainer;
        }while (self.middleContainer != container);
    }
    [left release];
    [right release];
    [mid release];
}

-(void)reloadData{
    _count = [self.dataSource numberOfContentViewsInScrollView:self];
    [self initialize];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint translate = [self.panGestureRecognizer translationInView:self];
    [self rearrangeContainers:translate];
    [self.infinityDelegate scrollView:self userDraggingOffset:translate];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate == NO){
        _index = [self indexOfSelectedChildView];
        [self.infinityDelegate scrollView:self 
                didStopAtChildViewOfIndex:_index];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _index = [self indexOfSelectedChildView];
    [self.infinityDelegate scrollView:self 
            didStopAtChildViewOfIndex:_index];
}

-(void)rearrangeContainers:(CGPoint)translate{
    if (_count == 0)
        return;
    if (translate.x > 0){
        //swap to right
        //show the left container
        if (self.contentOffset.x <= 0){
            //move the right most container to the left most
            [self setContentOffset:CGPointMake(self.bounds.size.width, 0)];
            InfinityScrollContainer* container = self.middleContainer.rightContainer;
            //load new view to the container
            NSInteger index = self.middleContainer.rightContainer.rightContainer.index;
            index = (index-1 + _count) % _count;
            container.index = index;
            [self loadContentViewToContainer:container];
            self.middleContainer = self.middleContainer.leftContainer;
            [self translateContainers];
        }
    }else if (translate.x < 0){
        //swap to left
        //show the right container 
        if (self.contentOffset.x >= self.contentSize.width - self.frame.size.width){
            //move the left most container to the right most
            [self setContentOffset:CGPointMake(self.contentSize.width - self.bounds.size.width*2, 0)];
            InfinityScrollContainer* container = self.middleContainer.leftContainer;
            NSInteger index = self.middleContainer.leftContainer.leftContainer.index;
            index = (index+1) % _count;
            container.index = index;
            [self loadContentViewToContainer:container];
            self.middleContainer = self.middleContainer.rightContainer;
            [self translateContainers];
        }
    }
}

-(void)loadContentViewToContainer:(InfinityScrollContainer*)container{
    [container addViewToContainer:[self.dataSource scrollView:self contentViewAtIndex:container.index]];
}

-(void)translateContainers{
    InfinityScrollContainer* container = self.middleContainer.leftContainer;
    CGAffineTransform transform = CGAffineTransformIdentity;
    do{
        container.view.transform = transform;
        container = container.rightContainer;
        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(self.bounds.size.width, 0));
    }while (container!=self.middleContainer.leftContainer);
}

-(NSInteger)indexOfSelectedChildView{
    return self.middleContainer.index;
}

-(void)moveToChildViewAtIndex:(NSInteger)index direction:(InfinityScrollViewDirection)direction animated:(BOOL)animated{
    
}

@end
