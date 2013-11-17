//
//  JFObject.m
//  JFramework
//
//  Created by Denis Jajčević on 31.10.2013..
//  Copyright (c) 2013. Denis Jajčević. All rights reserved.
//

#import "JFObject.h"

#pragma mark - validation


#pragma mark - category

@interface JFObject ()

@property (strong, nonatomic) NSArray *internalIgnoredFields;

@end

#pragma mark - implementation

@implementation JFObject

static NSArray *s_internalIgnoredFields;

static NSMutableDictionary *s_registeredClasses;

- (id)init
{
    self = [super init];
    if (self) {
        self.dictionary = [NSMutableDictionary dictionary];

    }
    return self;
}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:@selector(returnValue:)];
    return sig;
}

-(void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSString *propery = NSStringFromSelector(anInvocation.selector);
    id value = nil;
    if ([propery hasPrefix:@"set"]) {
        propery = [propery stringByReplacingOccurrencesOfString:@"set" withString:@""];
        propery = [propery stringByReplacingOccurrencesOfString:@":" withString:@""];
        NSRange firstCharRange = (NSRange){0,1};
        NSString *propertyLowercase = [[propery substringToIndex:1] lowercaseString];
        propery = [propery stringByReplacingCharactersInRange:firstCharRange withString:propertyLowercase];
        [anInvocation getArgument:&value atIndex:2];
        if (value != nil) {
            [self.dictionary setValue:value forKey:propery];
        }
    }
    else {
        value = self.dictionary[propery];
        [anInvocation setReturnValue:&value];
    }

}


/// dummy method
-(id) returnValue:(id) arg
{
    return arg;
}

-(NSArray *)ignoredSerializationFields
{
    if (!s_internalIgnoredFields) {
        s_internalIgnoredFields = @[@"internalIgnoredFields"];
    }
    return s_internalIgnoredFields;
}

+(void)load
{
    if (s_registeredClasses == nil) {
        s_registeredClasses = [NSMutableDictionary dictionary];
    }
    NSString *className = NSStringFromClass ([self class]);
    if (![[s_registeredClasses allKeys] containsObject:className]) {
        JFObjectMeta *metaData = [[JFObjectMeta alloc] initWithClass:[self class]];
        [s_registeredClasses setValue:metaData forKey:className];
        NSLog (@"Registered class %@", className);
    }
}

+ (JFObjectMeta *)metaData
{
    NSString *className = NSStringFromClass ([self class]);
    return s_registeredClasses[className];
}

-(JFObjectMeta *) metaData
{
    return [[self class] metaData];
}


-(BOOL)valid
{
    BOOL valid = YES;

    NSDictionary *validationDictionary = self.metaData.propertyAttributes[JFValidationKey];
    for (NSString *property in validationDictionary) {
        NSArray *propertyValidators = validationDictionary[property];
        NSObject *value = [self valueForKeyPath:property];
        for (JFValidator *validator in propertyValidators) {
            valid &= [validator validateValue:value];
        }
    }

    return valid;
}

-(BOOL) value:(NSString*) value matchesPattern:(NSString*) pattern
{
    assert(pattern != nil);
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSRange range = [regex rangeOfFirstMatchInString:value options:0 range:value.range];
    return range.length > 0;
}

-(NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    for (NSString *property in [[self class] metaData].propertyNames) {
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

    for (NSString *property in  [instance metaData].propertyNames) {
        Class propertyClass = [[self metaData] classForPropertyNamed:property];
        id value = nil;
        if ([property isEqualToString:@"instanceId"]) {
            value = dictionary[@"id"];
        }
        else {
            value = dictionary[property];
        }
        NSLog(@"Class:%@, property:%@, dictValueNil:%@", NSStringFromClass([self class]), property, @(value == nil));
        if (value != nil) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                if ([propertyClass isSubclassOfClass:jfObjectClass]) {
                    id instanceValue = [propertyClass fromDictionary:value];
                    if (instanceValue) {
                        [instance setValue:instanceValue forKeyPath:property];
                    }
                }
                else {
                    [instance setValue:value forKeyPath:property];
                }
            }

            else if([value isKindOfClass:[NSArray class]]) {
                if (propertyArrayItemClasses) {
                    Class arrayItemsClass = propertyArrayItemClasses[property];
                    if (arrayItemsClass && [arrayItemsClass isSubclassOfClass:jfObjectClass]) {
                        id instanceValues = [arrayItemsClass fromDictionaryArray:value];
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
