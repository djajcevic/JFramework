//
//  JFValidator.m
//  JFramework
//
//  Created by Denis Jajčević on 03.11.2013..
//  Copyright (c) 2013. Denis Jajčević. All rights reserved.
//

#import "JFValidator.h"

FOUNDATION_EXPORT_VALUE(JFValidationKey, @"JFValidationKey")
FOUNDATION_EXPORT_VALUE(JFValidationNotNullKey, @"JFValidationNotNullKey")
FOUNDATION_EXPORT_VALUE(JFValidationNotEmptyKey, @"JFValidationNotEmptyKey")
FOUNDATION_EXPORT_VALUE(JFValidationRegexKey, @"JFValidationRegexKey")
FOUNDATION_EXPORT_VALUE(JFValidationEmailKey, @"JFValidationEmailKey")

JFValidator const* JFNotNullValidator;

@implementation JFValidator

-(id)initWithKey:(NSString *)key andValidationBlock:(JFValidationBlock)block
{
    self = [super init];
    if (self) {
        self.key = key;
        self.validationBlock = block;
    }
    return self;
}

-(id)initWithKey:(NSString *)key controlValue:(id)controlValue andValidationBlock:(JFValidationBlock)block
{
    self = [self initWithKey:key andValidationBlock:block];
    if (self) {
        self.value = controlValue;
    }
    return self;
}

-(BOOL)validateValue:(id)value
{
    return self.validationBlock(self, value);
}

+(JFValidator *)JFNotNullValidator
{
    return [[JFValidator alloc] initWithKey:JFValidationNotNullKey andValidationBlock:^BOOL(JFValidator *validator, id value) {
        return value != nil;
    }];
}

+(JFValidator *)JFNotEmptyValidator
{
    return [[JFValidator alloc] initWithKey:JFValidationNotNullKey andValidationBlock:^BOOL(JFValidator *validator, id value) {
        if ([value isKindOfClass:[NSString class]]) {
            return [value length] > 0;
        }
        else {
            return NO;
        }
    }];
}

+(JFValidator *)JFEmailValidator
{
    return [[JFValidator alloc] initWithKey:JFValidationEmailKey andValidationBlock:^BOOL(JFValidator *validator, id value) {
        if ([value isKindOfClass:[NSString class]]) {
            return [value isValidEmail];
        }
        else {
            return NO;
        }
    }];
}

+(JFValidator *)JFRegexValidator
{
    return [[JFValidator alloc] initWithKey:JFValidationEmailKey andValidationBlock:^BOOL(JFValidator *validator, id value) {
        if ([value isKindOfClass:[NSString class]]) {
            return [value matches:validator.value];
        }
        else {
            return NO;
        }
    }];
}

+(JFValidator *)JFExactNumberValidator:(NSNumber *)number
{
    return [[JFValidator alloc] initWithKey:JFValidationEmailKey controlValue:number andValidationBlock:^BOOL(JFValidator *validator, id value) {
        if ([value isKindOfClass:[NSNumber class]]) {
            return [value isEqualToNumber:validator.value];
        }
        else {
            return NO;
        }
    }];
}

+(JFValidator *)JFExactStringValidator:(NSString *)string
{
    return [[JFValidator alloc] initWithKey:JFValidationEmailKey controlValue:string andValidationBlock:^BOOL(JFValidator *validator, id value) {
        if ([value isKindOfClass:[NSString class]]) {
            return [value isEqualToString:validator.value];
        }
        else {
            return NO;
        }
    }];
}

@end