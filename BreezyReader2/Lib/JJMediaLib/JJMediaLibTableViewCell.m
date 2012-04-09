//
//  JJMediaLibTableViewCell.m
//  BreezyReader2
//
//  Created by  on 12-2-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJMediaLibTableViewCell.h"
#import "JJMediaThumbView.h"
#import "JJMedia.h"
#import "JJMediaSource.h"

static CGFloat kDefaultThumbSpacing = 4.0f;
static CGFloat kDefaultThumbSize = 75.0f;
static NSUInteger kDefaultColumnCount = 4;

@interface JJMediaLibTableViewCell(){
    NSUInteger _index;
    CGPoint _thumbOrigin;
    
    CGFloat _thumbSize;
    CGFloat _thumbSpacing;
    CGFloat _columnCount;
    
    Class _thumbnailClass;
}

@property (nonatomic, retain) id<JJMediaSource> mediaSource;

-(void)layoutThumbnailViews;
-(void)resetThumbSize;
-(void)addThumbnailViewsToContentView;
-(void)assignMediaAtIndex:(NSUInteger)index toThumbView:(JJMediaThumbView*)view;
-(UIView*)generateThumbViewAtIndex:(NSInteger)index;

@end

@implementation JJMediaLibTableViewCell

@synthesize thumbnailViews = _thumbnailViews, mediaSource = _mediaSource;
@synthesize delegate = _delegate;

-(void)dealloc{
    self.thumbnailViews = nil;
    self.mediaSource = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier thumbSpacing:kDefaultThumbSpacing thumbSize:kDefaultThumbSize];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier thumbSpacing:(CGFloat)thumbSpacing thumbSize:(CGFloat)thumbSize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.thumbnailViews = [NSMutableArray array];
        _thumbSize = thumbSize;
        _thumbSpacing = thumbSpacing;
        _columnCount = kDefaultColumnCount;
        _thumbOrigin = CGPointMake(_thumbSpacing, 0);
        _thumbnailClass = NULL;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)setMediaSource:(id<JJMediaSource>)source withStartIndex:(NSUInteger)index;{
    self.mediaSource = source;
    _index = index;
    [self.thumbnailViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        UIView* view = (UIView*)obj;
        if (idx + _index > [self.mediaSource maxMediaIndex]){
            view.hidden = YES;
        }else{
            view.hidden = NO;
            [self assignMediaAtIndex:idx+_index toThumbView:obj];
        }
    }];
    [self setNeedsLayout];
}

-(void)setColumnCount:(NSUInteger)columnCount{
    if (columnCount != _columnCount){
        _columnCount = columnCount;
        [self addThumbnailViewsToContentView];
    }
    [self setNeedsLayout];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self layoutThumbnailViews];
}

-(void)layoutThumbnailViews{
}

-(void)resetThumbSize{
    _thumbSize = -1;
}

-(void)addThumbnailViewsToContentView{
    [self.thumbnailViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.thumbnailViews removeAllObjects];
    
    for (int i = 0; i < _columnCount; i++){
        UIView* thumb = [self generateThumbViewAtIndex:i];
        [self.thumbnailViews addObject:thumb];
        [self.contentView addSubview:thumb]; 
    }
}

-(void)assignMediaAtIndex:(NSUInteger)index toThumbView:(JJMediaThumbView*)view{
    [view setObject:[self.mediaSource mediaAtIndex:index]];
}

-(void)thumbTouched:(id)sender{
    JJMediaThumbView* thumb = sender;
    [thumb thumbTouched:thumb];
    NSUInteger index = [self.thumbnailViews indexOfObject:sender];
    [self.delegate mediaLibTableViewCell:self didSelectMediaAtIndex:index+_index];
}

-(void)thumbTouchedDown:(id)sender{
    JJMediaThumbView* thumb = sender;
    [thumb thumbTouchedDown:thumb];
}

-(void)thumbTouchMoveOut:(id)sender{
    JJMediaThumbView* thumb = sender;
    [thumb thumbTouchMoveOut:thumb];    
}

-(UIView*)generateThumbViewAtIndex:(NSInteger)index{
    id thumb = [[[_thumbnailClass alloc] init] autorelease];
    if ([thumb isKindOfClass:[UIControl class]]){
        [thumb addTarget:self action:@selector(thumbTouched:) forControlEvents:UIControlEventTouchUpInside];
        [thumb addTarget:self action:@selector(thumbTouchedDown:) forControlEvents:UIControlEventTouchDown];
        [thumb addTarget:self action:@selector(thumbTouchMoveOut:) forControlEvents:UIControlEventTouchDragOutside];
    }
    
    CGRect thumbFrame = CGRectMake(_thumbOrigin.x, _thumbOrigin.y,
                                   _thumbSize, _thumbSize);
    UIView* thumbnail = (UIView*)thumb;
    thumbFrame.origin.x += (_thumbSpacing + _thumbSize)*index;
    thumbnail.frame = thumbFrame;
    thumbnail.hidden = YES;
    
    return thumbnail;
}

-(NSInteger)startIndex{
    return _index;
}

-(UIView*)thumbViewAtIndex:(NSInteger)index{
    return [self.thumbnailViews objectAtIndex:index];
}

-(void)setThumbnailClass:(Class)thumbClass{
    _thumbnailClass = thumbClass;
}

-(void)willDisappear:(BOOL)animated{
    [self.thumbnailViews makeObjectsPerformSelector:@selector(willDisappear:) withObject:[NSNumber numberWithBool:animated]];
}

-(void)didDisappear:(BOOL)animated{
    [self.thumbnailViews makeObjectsPerformSelector:@selector(didDisappear:) withObject:[NSNumber numberWithBool:animated]];
}

-(void)willAppear:(BOOL)animated{
    [self.thumbnailViews makeObjectsPerformSelector:@selector(willAppear:) withObject:[NSNumber numberWithBool:animated]];
}

-(void)didAppear:(BOOL)animated{
    [self.thumbnailViews makeObjectsPerformSelector:@selector(didAppear:) withObject:[NSNumber numberWithBool:animated]];
}

@end
