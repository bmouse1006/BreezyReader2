//
//  InfinityScrollContainer.h
//  BreezyReader2
//
//  Created by 金 津 on 12-1-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfinityScrollContainer : NSObject{
    NSInteger _index;
    
    InfinityScrollContainer* _leftContainer;
    InfinityScrollContainer* _rightContainer;
}

@property (nonatomic, assign) InfinityScrollContainer* leftContainer;
@property (nonatomic, assign) InfinityScrollContainer* rightContainer;

@property (nonatomic, retain) UIView* view;
@property (nonatomic, assign) NSInteger index;

-(void)addViewToContainer:(UIView*)view;

-(id)initWithContainerFrame:(CGRect)frame;

@end
