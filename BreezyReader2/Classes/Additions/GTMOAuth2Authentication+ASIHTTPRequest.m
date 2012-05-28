//
//  GTMOAuth2Authentication+ASIHTTPRequest.m
//  BreezyReader2
//
//  Created by 金 津 on 12-2-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTMOAuth2Authentication+ASIHTTPRequest.h"

@class GTMOAuth2AuthorizationArgs;

@implementation GTMOAuth2Authentication (ASIHTTPRequest)

- (void)authorizeASIRequest:(ASIHTTPRequest *)request
          completionHandler:(void (^)(NSError *error))handler{
    GTMOAuth2AuthorizationArgs *args;
    args = [GTMOAuth2AuthorizationArgs argsWithRequest:request
                                              delegate:nil
                                              selector:NULL
                                     completionHandler:handler
                                                thread:[NSThread currentThread]];
    [self authorizeRequestArgs:args];
}

- (BOOL)authorizeRequestImmediateArgs:(GTMOAuth2AuthorizationArgs *)args {
    // This authorization entry point never attempts to refresh the access token,
    // but does call the completion routine
    id request = [args request];
    
    NSString *scheme = nil;
    if ([request isKindOfClass:[NSURLRequest class]]){
        scheme = [[request URL] scheme];
    }else{
        scheme = [[(ASIHTTPRequest*)request url] scheme];
    }
    BOOL isAuthorizableRequest = self.shouldAuthorizeAllRequests
    || [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame;
    if (!isAuthorizableRequest) {
        // Request is not https, so may be insecure
        //
        // The NSError will be created below
#if DEBUG
        NSLog(@"Cannot authorize request with scheme %@ (%@)", scheme, request);
#endif
    }
    
    NSString *accessToken = self.accessToken;
    if (isAuthorizableRequest && [accessToken length] > 0) {
        if (request) {
            // we have a likely valid access token
            NSString *value = [NSString stringWithFormat:@"%s %@",
                               GTM_OAUTH2_BEARER, accessToken];
            if ([request isKindOfClass:[NSURLRequest class]]){
                [request setValue:value forHTTPHeaderField:@"Authorization"];
            }else{
                [(ASIHTTPRequest*)request addRequestHeader:@"Authorization" value:value];
            }
        }
        
        // We've authorized the request, even if the previous refresh
        // failed with an error
        [args setError:nil];
    } else if ([args error] == nil) {
        NSDictionary *userInfo = nil;
        if (request) {
            userInfo = [NSDictionary dictionaryWithObject:request
                                                   forKey:kGTMOAuth2ErrorRequestKey];
        }
        NSInteger code = (isAuthorizableRequest ?
                          kGTMOAuth2ErrorAuthorizationFailed :
                          kGTMOAuth2ErrorUnauthorizableRequest);
        NSError* error = [NSError errorWithDomain:kGTMOAuth2ErrorDomain 
                                             code:code
                                         userInfo:userInfo];
        [args setError:error];
    }
    
    // Invoke any callbacks on the proper thread
    if ([args delegate] || [args performSelector:@selector(completionHandler)]) {
        NSThread *targetThread = [args thread];
        BOOL isSameThread = [targetThread isEqual:[NSThread currentThread]];
        
        [self performSelector:@selector(invokeCallbackArgs:)
                     onThread:targetThread
                   withObject:args
                waitUntilDone:isSameThread];
    }
    
    BOOL didAuth = ([args error] == nil);
    return didAuth;
}

@end
