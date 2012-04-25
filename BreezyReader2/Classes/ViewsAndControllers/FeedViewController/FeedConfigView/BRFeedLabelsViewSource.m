//
//  BRFeedLabelsViewSource.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "BRFeedConfigViewController.h"
#import "BRFeedLabelsViewSource.h"
#import "GoogleReaderClient.h"
#import "BRFeedLabelCell.h"
#import "BRFeedLabelNewCell.h"

@interface BRFeedLabelsViewSource ()

@property (nonatomic, retain) NSArray* allLabels;

@end

@implementation BRFeedLabelsViewSource

@synthesize allLabels = _allLabels;  
@synthesize sectionView = _sectionView;

-(void)dealloc{
    self.sectionView = nil;
    self.allLabels = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.allLabels = [GoogleReaderClient tagListWithType:BRTagTypeLabel];
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        self.sectionView.titleLabel.text = NSLocalizedString(@"title_label", nil);
    }
    return self;
}

-(UIView*)sectionView{
    return _sectionView;
}

-(CGFloat)heightForHeader{
    return self.sectionView.bounds.size.height;
}

-(NSInteger)numberOfRowsInSection{
    return [self.allLabels count]+1;
}

-(id)tableView:(UITableView*)tableView cellForRow:(NSInteger)index{
    id cell = nil;
    if (index != [self.allLabels count]){
        cell = [tableView dequeueReusableCellWithIdentifier:@"BRFeedLabelCell"];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BRFeedLabelCell" owner:nil options:nil] objectAtIndex:0];
        }
        GRTag* tag = [self.allLabels objectAtIndex:index];
        ((BRFeedLabelCell*)cell).title = tag.label;
        if ([self.subscription.categories containsObject:tag.ID]){
            ((BRFeedLabelCell*)cell).isChecked = YES;
        }else{
            ((BRFeedLabelCell*)cell).isChecked = NO;
        }
    }else{
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BRFeedLabelNewCell" owner:nil options:nil] objectAtIndex:0];
    }
    
    return cell;
}

-(CGFloat)heightOfRowAtIndex:(NSInteger)index{
    return 40.0f;
}

-(void)didSelectRowAtIndex:(NSInteger)index{
    if (index == [self.allLabels count]){
        //add new selected;
        [self.tableController showAddNewTagView];
    }
}

@end
