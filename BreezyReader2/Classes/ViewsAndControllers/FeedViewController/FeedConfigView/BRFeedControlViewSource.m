//
//  BRFeedControlViewSource.m
//  BreezyReader2
//
//  Created by 金 津 on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BRFeedControlViewSource.h"
#import "BRFeedConfigBaseCell.h"

@interface BRFeedControlViewSource ()

@end

@implementation BRFeedControlViewSource

@synthesize sectionView = _sectionView;
@synthesize container = _container;

-(void)dealloc{
    self.sectionView = nil;
    self.container = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        self.sectionView.titleLabel.text = NSLocalizedString(@"title_feedoperation", nil);
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
    return 1;
}

-(id)tableView:(UITableView*)tableView cellForRow:(NSInteger)index{
//    return self.view;
    UITableViewCell* cell = [[[BRFeedConfigBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    [cell.contentView addSubview:self.container];
    return cell;
}

-(CGFloat)heightOfRowAtIndex:(NSInteger)index{
    return self.container.bounds.size.height;
}

#pragma mark - action methods
-(IBAction)unsubscriebButtonClicked:(id)sender{
    
}

-(IBAction)renameButtonClicked:(id)sender{

}

@end
