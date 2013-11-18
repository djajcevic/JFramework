//
//  NSObject+Serialization.m
//  JFramework
//
//  Created by Denis Jajčević on 31.10.2013..
//  Copyright (c) 2013. Denis Jajčević. All rights reserved.
//

#import "NSObject+Serialization.h"

#import "JFObject.h"

@implementation NSObject (Serialization)

@dynamic ignoredSerializationFields;

-(JFObjectMeta *)metaData
{
    return [[JFObjectMeta alloc] initWithClass:[self class]];
}

-(NSArray *)ignoredSerializationFields
{
    return @[];
}

-(NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    for (NSString *property in self.metaData.propertyNames) {
        if ([[self ignoredSerializationFields] containsObject:property])
            continue;
        id value = [self valueForKeyPath:property];
        if (value == nil) {
            continue;
        }
        Class jfObjectClass = [JFObject class];
        Class valueClass = [value class];
        if ([valueClass isSubclassOfClass:jfObjectClass]) {
            [dict setValue:[value toDictionary] forKey:property];
        }
        else if ([valueClass isSubclassOfClass:[NSArray class]]) {
            [dict setValue:[[self class] toDictionaryArray:value] forKey:property];
        }
        else {
            [dict setValue:value forKey:property];
        }
    }

    return [dict copy];
}

+(NSArray *)toDictionaryArray:(NSArray *)array
{
    if (!array)
        return nil;

    NSMutableArray *result = [NSMutableArray array];

    if ([array count] == 0) {
        return result;
    }

    for (JFObject *object in array) {
        [result addObject:[object toDictionary]];
    }

    return result;
}

-(NSData*) toJson
{
    return [NSJSONSerialization dataWithJSONObject:self.toDictionary options:0 error:nil];
}

+(NSData *)toJsonArray:(NSArray *)array
{
    if (!array || [array count] == 0)
        return nil;

    NSArray *resultArray = [self toDictionaryArray:array];
    if (!resultArray || [resultArray count] == 0)
        return nil;

    NSData *data = [NSJSONSerialization dataWithJSONObject:resultArray options:0 error:nil];
    return data;
}

-(NSString*) toJsonString
{
    return [[NSString alloc] initWithData:self.toJson encoding:NSUTF8StringEncoding];
}

+(NSString *)toJsonArrayString:(NSArray *)array
{
    if (!array || [array count] == 0)
        return nil;
    NSData *data = [self toJsonArray:array];

    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+(instancetype)fromDictionary:(NSDictionary *)dictionary
{
    id instance = [[self class] new];
    Class jfObjectClass = [JFObject class];
    NSDictionary *propertyAttributes = [[instance metaData] propertyAttributes];
    NSDictionary *propertyArrayItemClasses;
    if (propertyAttributes) {
        propertyArrayItemClasses = propertyAttributes[kSerializationPropertyArrayItemsClassKey];
    }
    for (NSString *property in self.metaData.propertyNames) {
        Class propertyClass = [self.metaData classForPropertyNamed:property];
        id value = dictionary[property];
        if (value != nil) {
            if ([value isKindOfClass:[NSDictionary class]] && [propertyClass isSubclassOfClass:jfObjectClass]) {
                id instanceValue = [self fromDictionary:value];
                if (instanceValue) {
                    [instance setValue:instanceValue forKeyPath:property];
                }
            }
            else if([value isKindOfClass:[NSArray class]]) {
                if (propertyArrayItemClasses) {
                    Class arrayItemsClass = propertyArrayItemClasses[property];
                    if (arrayItemsClass && [arrayItemsClass isSubclassOfClass:jfObjectClass]) {
                        id instanceValues = [self fromDictionaryArray:value];
                        [instance setValue:instanceValues forKey:property];
                    }
                }
                else {
                    // TODO: logg message
                }
            }
            else {
                [instance setValue:value forKeyPath:property];
            }
        }
    }
    return instance;
}

+(NSArray*)fromDictionaryArray:(NSArray *)dictionaryArray
{
    NSMutableArray *array = [NSMutableArray array];

    for (NSDictionary *dictionary in dictionaryArray) {
        if (![dictionary isKindOfClass:[NSDictionary class]])
            return dictionaryArray;
        [array addObject:[self fromDictionary:dictionary]];
    }

    return array;
}

+(instancetype)fromJson:(NSData *)data
{
    id instanceData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (instanceData) {
        if ([instanceData isKindOfClass:[NSDictionary class]]) {
            return [self fromDictionary:instanceData];
        }
    }
    return nil;
}

+(NSArray *)fromJsonArray:(NSData *)data
{
    id instanceData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (instanceData) {
        if ([instanceData isKindOfClass:[NSArray class]]) {
            return [self fromDictionaryArray:instanceData];
        }
    }
    return nil;
}

+(instancetype)fromJsonString:(NSString *)string
{
    if (!string)
        return nil;

    NSData *dataFromString = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (!dataFromString)
        return nil;

    return [self fromJson:dataFromString];
}

+(NSArray *)fromJsonArrayString:(NSString *)string
{
    if (!string)
        return nil;

    NSData *dataFromString = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (!dataFromString)
        return nil;

    id instanceData = [NSJSONSerialization JSONObjectWithData:dataFromString options:0 error:nil];
    if (instanceData) {
        if ([instanceData isKindOfClass:[NSArray class]]) {
            return [self fromDictionaryArray:instanceData];
        }
    }
    return nil;
}

@end
