//
//  GTMOAuthAuthentication+ASIHTTPRequest.m
//  BreezyReader2
//
//  Created by 金 津 on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GTMOAuthAuthentication+ASIHTTPRequest.h"
#import "ASIHTTPRequest.h"

@class OAuthParameter;

@implementation GTMOAuthAuthentication (ASIHTTPRequest)

- (void)addAuthorizationHeaderToRequest:(NSMutableURLRequest *)request
                                forKeys:(NSArray *)keys {
    // make all the parameters, including a signature for all
    NSMutableArray *params = [self paramsForKeys:keys request:request];
    
    // split the params into "oauth_" params which go into the Auth header
    // and others which get added to the query
    NSMutableArray *oauthParams = [NSMutableArray array];
    NSMutableArray *extendedParams = [NSMutableArray array];
    
    for (OAuthParameter *param in params) {
        NSString *name = [param name];
        BOOL hasPrefix = [name hasPrefix:@"oauth_"];
        if (hasPrefix) {
            [oauthParams addObject:param];
        } else {
            [extendedParams addObject:param];
        }
    }
    
    NSString *paramStr = [[self class] paramStringForParams:oauthParams
                                                     joiner:@", "
                                                shouldQuote:YES
                                                 shouldSort:NO];
    
    // include the realm string, if any, in the auth header
    // http://oauth.net/core/1.0a/#auth_header
    NSString *realmParam = @"";
    NSString *realm = [self realm];
    if ([realm length] > 0) {
        NSString *encodedVal = [[self class] encodedOAuthParameterForString:realm];
        realmParam = [NSString stringWithFormat:@"realm=\"%@\", ", encodedVal];
    }
    
    // set the parameters for "oauth_" keys and the realm
    // in the authorization header
    NSString *authHdr = [NSString stringWithFormat:@"OAuth %@%@",
                         realmParam, paramStr];
    if ([request isMemberOfClass:[ASIHTTPRequest class]]){
        ASIHTTPRequest* req = (ASIHTTPRequest*)request;
        [req addRequestHeader:@"Authorization" value:authHdr];
    }else{
        [request setValue:authHdr forHTTPHeaderField:@"Authorization"];
    }
    
    // add any other params as URL query parameters
    if ([extendedParams count] > 0) {
        [self addParams:extendedParams toRequest:request];
    }
    
#if GTL_DEBUG_OAUTH_SIGNING
    NSLog(@"adding auth header: %@", authHdr);
    NSLog(@"final request: %@", request);
#endif
}

- (NSString *)normalizedRequestURLStringForRequest:(NSURLRequest *)request {
    // http://oauth.net/core/1.0a/#anchor13

    NSURL *url = nil;
    if ([request isMemberOfClass:[ASIHTTPRequest class]]){
        url = [[(ASIHTTPRequest*)request url] absoluteURL];
    }else{
        url = [[request URL] absoluteURL];
    }
    
    NSString *scheme = [[url scheme] lowercaseString];
    NSString *host = [[url host] lowercaseString];
    int port = [[url port] intValue];
    
    // NSURL's path method has an unfortunate side-effect of unescaping the path,
    // but CFURLCopyPath does not
    CFStringRef cfPath = CFURLCopyPath((CFURLRef)url);
    NSString *path = [NSMakeCollectable(cfPath) autorelease];
    
    // include only non-standard ports for http or https
    NSString *portStr;
    if (port == 0
        || ([scheme isEqual:@"http"] && port == 80)
        || ([scheme isEqual:@"https"] && port == 443)) {
        portStr = @"";
    } else {
        portStr = [NSString stringWithFormat:@":%u", port];
    }
    
    if ([path length] == 0) {
        path = @"/";
    }
    
    NSString *result = [NSString stringWithFormat:@"%@://%@%@%@",
                        scheme, host, portStr, path];
    return result;
}

- (NSString *)signatureForParams:(NSMutableArray *)params
                         request:(NSURLRequest *)request {
    // construct signature base string per
    // http://oauth.net/core/1.0a/#signing_process
    NSString *requestURLStr = [self normalizedRequestURLStringForRequest:request];
    NSString *method = nil;
    if ([request isMemberOfClass:[ASIHTTPRequest class]]){
        method = [[(ASIHTTPRequest*)request requestMethod] uppercaseString];
    }else{
        method = [[request HTTPMethod] uppercaseString];
    }
    if ([method length] == 0) {
        method = @"GET";
    }
    
    // the signature params exclude the signature
    NSMutableArray *signatureParams = [NSMutableArray arrayWithArray:params];
    
    // add request query parameters
    [[self class] addQueryFromRequest:request toParams:signatureParams];
    
    // add parameters from the POST body, if any
    [[self class] addBodyFromRequest:request toParams:signatureParams];
    
    NSString *paramStr = [[self class] paramStringForParams:signatureParams
                                                     joiner:@"&"
                                                shouldQuote:NO
                                                 shouldSort:YES];
    
    // the base string includes the method, normalized request URL, and params
    NSString *requestURLStrEnc = [[self class] encodedOAuthParameterForString:requestURLStr];
    NSString *paramStrEnc = [[self class] encodedOAuthParameterForString:paramStr];
    
    NSString *sigBaseString = [NSString stringWithFormat:@"%@&%@&%@",
                               method, requestURLStrEnc, paramStrEnc];
    
    NSString *privateKey = [self privateKey];
    NSString *signatureMethod = [self signatureMethod];
    NSString *signature = nil;
    
#if GTL_DEBUG_OAUTH_SIGNING
    NSLog(@"signing request: %@\n", request);
    NSLog(@"signing params: %@\n", params);
#endif
    
    if ([signatureMethod isEqual:kGTMOAuthSignatureMethodHMAC_SHA1]) {
        NSString *tokenSecret = [self tokenSecret];
        signature = [[self class] HMACSHA1HashForConsumerSecret:privateKey
                                                    tokenSecret:tokenSecret
                                                           body:sigBaseString];
#if GTL_DEBUG_OAUTH_SIGNING
        NSLog(@"hashing: %@&%@",
              privateKey ? privateKey : @"",
              tokenSecret ? tokenSecret : @"");
        NSLog(@"base string: %@", sigBaseString);
        NSLog(@"signature: %@", signature);
#endif
    }
    
#if GTL_OAUTH_SUPPORTS_RSASHA1_SIGNING
    else if ([signatureMethod isEqual:kGTMOAuthSignatureMethodRSA_SHA1]) {
        signature = [[self class] RSASHA1HashForString:sigBaseString
                                   privateKeyPEMString:privateKey];
    }
#endif
    
    return signature;
}

+ (void)addQueryFromRequest:(NSURLRequest *)request
                   toParams:(NSMutableArray *)array {
    // get the query string from the request
    NSString *query = nil;
    if ([request isMemberOfClass:[ASIHTTPRequest class]]){
        query = [[(ASIHTTPRequest*)request url] query];
    }else{
        query = [[request URL] query];
    }
    [self addQueryString:query toParams:array];
}

+ (void)addBodyFromRequest:(NSURLRequest *)request
                  toParams:(NSMutableArray *)array {
    // add non-GET form parameters to the array of param objects
    NSString* method = nil;
    NSString* type = nil;
    NSData* data = nil;
    if ([request isMemberOfClass:[ASIHTTPRequest class]]){
        ASIHTTPRequest* req = (ASIHTTPRequest*)request;
        method = [req requestMethod];
        [req buildRequestHeaders];
        type = [req.requestHeaders objectForKey:@"Content-Type"];
        [req buildPostBody];
        data = req.postBody;
    }else {
        method = [request HTTPMethod];
        type = [request valueForHTTPHeaderField:@"Content-Type"];
        data = [request HTTPBody];
    }
//    NSString *method = [request HTTPMethod];
    if (method != nil && ![method isEqual:@"GET"]) {
//        NSString *type = [request valueForHTTPHeaderField:@"Content-Type"];
        if ([type hasPrefix:@"application/x-www-form-urlencoded"]) {
//            NSData *data = [request HTTPBody];
            if ([data length] > 0) {
                NSString *str = [[[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding] autorelease];
                if ([str length] > 0) {
                    [[self class] addQueryString:str toParams:array];
                }
            }
        }
    }
}

@end
