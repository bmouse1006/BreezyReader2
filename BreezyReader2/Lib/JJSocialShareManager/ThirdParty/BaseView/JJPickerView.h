//
//  JJPicker.h
//  BreezyReader2
//
//  Created by 金 津 on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseView.h"

@class JJPickerView;

@protocol JJPickerViewDataSource <NSObject>

@required
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;

@end

@interface JJPickerView : BaseView 

@property (nonatomic, retain) IBOutlet UIPickerView* picker;
@property (nonatomic, retain) IBOutlet UIView* pickerContainer;

@property (nonatomic, assign) id<UIPickerViewDelegate> delegate;
@property (nonatomic, assign) id<UIPickerViewDataSource> dataSource;

@property (nonatomic, retain) IBOutlet UILabel* titleLabel;

@end
