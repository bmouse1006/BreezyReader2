//
//  JJMediaSource.h
//  MeetingPlatform
//
//  Created by  on 12-2-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JJMedia;

@protocol JJMediaSourceDelegate

-(void)sourceLoadFinished;

@end

@protocol JJMediaSource <NSObject>

/**
 * The title of this collection of medias.
 */
@property (nonatomic, readonly) NSString* title;

/**
 * The total number of photos in the source, independent of the number that have been loaded.
 */
@property (nonatomic, readonly) NSInteger numberOfMedias;

/**
 * The maximum index of photos that have already been loaded.
 */
@property (nonatomic, readonly) NSInteger maxMediaIndex;

- (id)mediaAtIndex:(NSInteger)index;

-(void)loadSourceMore:(BOOL)more;

@end
