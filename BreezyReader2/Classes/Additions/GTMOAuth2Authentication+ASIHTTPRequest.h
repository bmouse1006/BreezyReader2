//
//  GTMOAuth2Authentication+ASIHTTPRequest.h
//  BreezyReader2
//
//  Created by 金 津 on 12-2-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTMOAuth2Authentication.h"
#import "ASIHTTPRequest.h"

@interface GTMOAuth2Authentication (ASIHTTPRequest)

- (void)authorizeASIRequest:(ASIHTTPRequest *)request
       completionHandler:(void (^)(NSError *error))handler;

@end
