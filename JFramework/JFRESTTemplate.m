//
//  JFRESTTemplate.m
//  JFUtilNetwork
//
//  Created by Denis Jajčević on 1.3.2013..
//  Copyright (c) 2013. JajcevicFramework. All rights reserved.
//

#import "JFRESTTemplate.h"

@interface JFRESTTemplate ()

- (void)resolveParametersFromRequestTemplate;

@property (nonatomic, retain) NSString            *p_requestTemplate;
@property (nonatomic, retain) NSMutableArray      *p_parameters;
@property (nonatomic, retain) NSMutableDictionary *p_requestParametersAndValues;

@end

@implementation JFRESTTemplate

- (id)initWithRequestTemplate:(NSString *)requestTemplate
{
    self = [super init];
    if (self) {
        assert(requestTemplate);
        self.p_requestTemplate = requestTemplate;


        self.p_parameters = [NSMutableArray array];

        [self resolveParametersFromRequestTemplate];

        self.p_requestParametersAndValues = [NSMutableDictionary dictionaryWithCapacity:_p_parameters.count];

        for (NSString *parameter in _p_parameters) {
            [_p_requestParametersAndValues setObject:@"" forKey:parameter];
        }

    }
    return self;
}

- (void)resolveParametersFromRequestTemplate
{
    const char *cRequestTemplate = [_p_requestTemplate UTF8String];
    NSRange  range;
    for (int i                   = 0; i < _p_requestTemplate.length; i++) {
        char character = cRequestTemplate[i];
        if (character == '{') {
            range.location = i + 1;
        }
        else if (character == '}') {
            range.length = i - range.location;
            NSString *key = [_p_requestTemplate substringWithRange:range];
            [_p_parameters addObject:key];
        }
    }
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([[_p_requestParametersAndValues allKeys] containsObject:key]) {
        [_p_requestParametersAndValues setValue:[value description] forKey:key];
    }
}

- (NSString *)requestTemplate
{
    return [_p_requestTemplate copy];
}

- (NSArray *)requestParameters
{
    return [_p_parameters copy];
}

- (NSDictionary *)requestParametersAndValues
{
    return _p_requestParametersAndValues;
}

- (NSString *)preparedRequest
{
    NSMutableString *preparedRequest = [NSMutableString stringWithFormat:@"%@/%@", (_requestDomain ? _requestDomain : @""), _p_requestTemplate];

    for (int parameterIndex = 0; parameterIndex < _p_parameters.count; parameterIndex++) {

        NSString *parameter = [_p_parameters objectAtIndex:parameterIndex];

        NSString *value = [[_p_requestParametersAndValues objectForKey:parameter] description];

        parameter = [NSString stringWithFormat:@"{%@}", [_p_parameters objectAtIndex:parameterIndex]];

        NSRange range = [preparedRequest rangeOfString:parameter];

        [preparedRequest replaceCharactersInRange:range withString:value];
    }
    return [preparedRequest stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSURLRequest *)preparedURLRequest
{
    return [NSURLRequest requestWithURL:[NSURL URLWithString:[self preparedRequest]]];
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"\nJFRESTTemplate(%@) {\n", [super description]];
    [description appendFormat:@"Domain: %@", _requestDomain];
    [description appendFormat:@"\nRequest: %@", _p_requestTemplate];
    [description appendFormat:@"\nParameters: %@", _p_requestParametersAndValues];
    [description appendString:@"\n}"];
    return [description copy];
}

- (id)copyWithZone:(NSZone *)zone
{
    JFRESTTemplate *copy = [[JFRESTTemplate alloc] initWithRequestTemplate:_p_requestTemplate];
    copy.p_parameters                 = [_p_parameters copy];
    copy.p_requestParametersAndValues = [_p_requestParametersAndValues mutableCopy];
    return copy;
}

@end
