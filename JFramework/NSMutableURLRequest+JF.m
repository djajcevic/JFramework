//
//  NSMutableURLRequest+JF.m
//  JFUtilNetwork
//
//  Created by Denis Jajčević on 28.2.2013..
//  Copyright (c) 2013. JajcevicFramework. All rights reserved.
//

#import "NSString+JF.h"

@implementation NSMutableURLRequest (JF)

+ (NSMutableURLRequest *)postRequestWithUrl:(NSString *)url headerAtt:(NSDictionary *)headerAtt andBodyAtt:(NSDictionary *)bodyAttr
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url URL]];

    // body start //
    NSMutableString *body = [NSMutableString string];
    for (NSString   *key in bodyAttr) {
        [body appendFormat:@"%@=%@&", key, [bodyAttr valueForKey:key]];
    }
    if (body.length)
        [body replaceCharactersInRange:(NSRange) {body.length - 1, 1} withString:@""];
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    // body end //

    // header start //
    request.allHTTPHeaderFields = headerAtt;
    // header end //

    request.HTTPMethod = @"POST";

    return request;
}

+ (NSMutableURLRequest *)post:(NSString *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url URL] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
    request.HTTPMethod = @"POST";

    return request;
}

+(NSMutableURLRequest *)get:(NSString *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url URL] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
    request.HTTPMethod = @"GET";

    return request;
}

+(NSMutableURLRequest *)getWithPathValues:(NSString *)urlFormat, ...
{
    NSString * resultUrl = @"";
    va_list alist;

    if(urlFormat)
    {
        va_start(alist, urlFormat);
    	resultUrl = [[NSString alloc] initWithFormat:urlFormat arguments:alist];
    }

    return [NSMutableURLRequest get:resultUrl];
}

- (NSMutableURLRequest *)body:(NSDictionary *)attr
{
    // body start //
    NSMutableString *body = [NSMutableString string];
    for (NSString   *key in attr) {
        [body appendFormat:@"%@=%@&", key, [attr valueForKey:key]];
    }
    if (body.length)
        [body replaceCharactersInRange:(NSRange) {body.length - 1, 1} withString:@""];
    self.HTTPBody = [[body escaped] dataUsingEncoding:NSUTF8StringEncoding];
    // body end //
    return self;
}

-(NSMutableURLRequest *)jsonBody:(NSDictionary *)attr
{
    NSData *jsonString = [NSJSONSerialization dataWithJSONObject:attr options:0 error:nil];
    self.HTTPBody = jsonString;
    [self setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return self;
}

- (NSMutableURLRequest *)headers:(NSDictionary *)attr
{
    // header start //
    for (NSString *key in attr) {
        [self setValue:[[attr objectForKey:key] escaped] forHTTPHeaderField:key];
    }
    // header end //
    return self;
}

-(NSMutableURLRequest *)setTimeoutInSec:(int)timeout
{
    self.timeoutInterval = timeout;
    return self;
}

@end
