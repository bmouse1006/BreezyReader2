//
//  JJMediaDataSource.m
//  BreezyReader2
//
//  Created by  on 12-2-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JJMediaDataSource.h"
#import "JJMediaLibTableViewCell.h"
#import "JJMediaSource.h"
#import "JJMediaThumbView.h"

static CGFloat kDefaultThumbSize = 75.0f;
static CGFloat kDefaultThumbSapcing = 4.0f;

@interface JJMediaDataSource (){
    CGFloat _thumbSize;
    CGFloat _thumbSpacing;
}

@property (nonatomic, retain) id<JJMediaSource> mediaSource;

- (NSInteger)columnCountForView:(UIView *)view;

@end

@implementation JJMediaDataSource

@synthesize delegate = _delegate;
@synthesize mediaSource = _mediaSource;

-(id)initWithMediaSource:(id<JJMediaSource>)mediaSource delegate:(id<JJMediaLibTableViewCellDelegate>)delegate{
    self = [super init];
    if (self){
        self.mediaSource = mediaSource;
        self.delegate = delegate;
        _thumbSize = kDefaultThumbSize;
        _thumbSpacing = kDefaultThumbSapcing;
    }
    
    return self;
}

-(void)dealloc{
    self.mediaSource = nil;
    [super dealloc];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return (self.mediaSource.maxMediaIndex>=0)?1:0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.mediaSource.maxMediaIndex/[self columnCountForView:tableView] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MediaLibCell";
    NSUInteger columnCount = [self columnCountForView:tableView];
    JJMediaLibTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[JJMediaLibTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier thumbSpacing:_thumbSpacing thumbSize:_thumbSize] autorelease];
        cell.delegate = self.delegate;
        [cell setThumbnailClass:[self classForThumbnail]];
        [cell setColumnCount:columnCount];
    }
    
    [cell setMediaSource:self.mediaSource withStartIndex:indexPath.row*columnCount];
    
    return cell;
}

- (NSInteger)columnCountForView:(UIView *)view {
    CGFloat width = view.bounds.size.width;
    return floorf((width - _thumbSpacing*2) / (_thumbSpacing+_thumbSize) + 0.1);
}

-(void)setThumbSize:(CGFloat)thumbSize thumbSpacing:(CGFloat)thumbSpacing{
    _thumbSize = thumbSize;
    _thumbSpacing = thumbSpacing;
}

-(Class)classForThumbnail{
    return [JJMediaThumbView class];
}

@end
