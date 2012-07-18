//
//  FeedSearchDataSource.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedSearchDataSource.h"
#import "NSString+SBJSON.h"
#import "ASIHTTPRequest.h"

@interface FeedSearchDataSource()

@end

@implementation FeedSearchDataSource


-(id)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id cell = nil;
    if (_searching){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchLoadingCell" owner:nil options:nil] objectAtIndex:0];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"BRFeedDetailCell"];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BRFeedDetailCell" owner:nil options:nil] objectAtIndex:0];
        }
        
        [cell performSelector:@selector(setItem:) withObject:[self.results objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

-(void)startSearchWithKeywords:(NSString *)keywords{
    [super startSearchWithKeywords:keywords];
    
    [self.client clearAndCancel];
    self.client = [GoogleReaderClient clientWithDelegate:self action:@selector(receivedFeedSearchingResult:)];
    
    [self.client searchFeedsWithKeywords:keywords];
}

-(void)receivedFeedSearchingResult:(GoogleReaderClient*)client{
    if (client.error == nil){
        self.results = [client.responseFeedSearchingJSONValue objectForKey:@"entries"];
        [self searchFinished];
    }else{
        //error handler
    }
}

-(NSString*)title{
    return @"Searching feeds...";
}

@end
