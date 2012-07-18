//
//  BRFeedLabelsViewSource.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "BRFeedConfigViewController.h"
#import "BRFeedLabelsViewSource.h"
#import "BRFeedLabelCell.h"
#import "BRFeedLabelNewCell.h"
#import "GoogleReaderClient.h"
#import "GoogleReaderClientHelper.h"

@interface BRFeedLabelsViewSource ()

@property (nonatomic, strong) NSArray* allLabels;
@property (nonatomic, strong) NSMutableSet* selectedTags;

@end

@implementation BRFeedLabelsViewSource

@synthesize allLabels = _allLabels;  
@synthesize sectionView = _sectionView;
@synthesize selectedTags = _selectedTags;


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

-(void)subscriptionChanged:(GRSubscription *)newSub{
    self.selectedTags = [NSMutableSet setWithSet:newSub.categories];
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
        if ([self.selectedTags containsObject:tag.ID]){
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
    }else{
        GRTag* tag = [self.allLabels objectAtIndex:index];
        if ([self.selectedTags containsObject:tag.ID]){
            [self.selectedTags removeObject:tag.ID];
        }else{
            [self.selectedTags addObject:tag.ID];
        }
        
        [self.tableController reloadRowsFromSource:self row:index animated:NO];
    }
    
    [self commitChange];
}

-(void)viewDidDisappear{

}

-(void)commitChange{
    //commit label change
    NSSet* conjoint = [self.selectedTags objectsPassingTest:^(id obj, BOOL* stop){
        if ([self.subscription.categories containsObject:obj]){
            return YES;
        }
        return NO;
    }];
    
    NSSet* tagToAdd = [self.selectedTags objectsPassingTest:^(id obj, BOOL* stop){
        if ([conjoint containsObject:obj]){
            return NO;
        }
        return YES;
    }];
    
    NSSet* tagToRemove = [self.subscription.categories objectsPassingTest:^(id obj, BOOL* stop){
        if ([conjoint containsObject:obj]){
            return NO;
        }
        return YES;
    }];
    DebugLog(@"tag to add: %@", tagToAdd);
    DebugLog(@"tag to remove: %@", tagToRemove);
    for (NSString* tag in tagToAdd){
        GoogleReaderClient* client = [GoogleReaderClientHelper client];
        [client editSubscription:self.subscription.ID tagToAdd:tag tagToRemove:nil];
    }    
    for (NSString* tag in tagToRemove){
        GoogleReaderClient* client = [GoogleReaderClientHelper client];
        [client editSubscription:self.subscription.ID tagToAdd:nil tagToRemove:tag];
    } 
}

@end
