//
//  JFRESTService.m
//  JFUtilNetwork
//
//  Created by Denis Jajčević on 1.3.2013..
//  Copyright (c) 2013. JajcevicFramework. All rights reserved.
//

#import "JFRESTService.h"

@interface JFRESTService ()

- (void)prepareRequest:(JFRESTTemplate *)template withFirstParam:(id)firstParam andVaArgs:(va_list)valist;

@end

@implementation JFRESTService


- (id)init
{
    self = [super init];
    if (self) {
        self.requests = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithDomain:(NSString *)domain
{
    self = [self init];
    if (self) {
        self.domain = domain;
        self.domain = [self.domain stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    }
    return self;
}

- (void)registerRequest:(NSString *)request forName:(NSString *)name
{
    JFRESTTemplate *template = [[JFRESTTemplate alloc] initWithRequestTemplate:request];
    template.requestDomain = _domain;
    [self.requests setObject:template forKey:name];
}

- (void)prepareRequest:(JFRESTTemplate *)template withFirstParam:(id)firstParam andVaArgs:(va_list)valist
{
    NSArray *parameters = template.requestParameters;

    int     i     = 0;
    for (id value = firstParam; i < parameters.count; i++) {
        if (i > 0 && i < parameters.count) {
            value = va_arg(valist, id);
        }
        NSString *parameterKey = [parameters objectAtIndex:i];
        [template setValue:[value description] forKey:parameterKey];
    }
}

- (NSString *)preparedRequest:(NSString *)requestName withParameter:(id)parameter, ...
{

    va_list args;
    va_start(args, parameter);

    JFRESTTemplate *template = [[_requests objectForKey:requestName] copy];

    [self prepareRequest:template withFirstParam:parameter andVaArgs:args];

    va_end(args);

    return [template preparedRequest];
}

- (NSURLRequest *)preparedURLRequest:(NSString *)requestName withParameter:(id)parameter, ...
{
    va_list args;
    va_start(args, parameter);

    JFRESTTemplate *template = [[_requests objectForKey:requestName] copy];

    [self prepareRequest:template withFirstParam:parameter andVaArgs:args];

    va_end(args);

    return [template preparedURLRequest];
}

@end
