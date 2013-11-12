//
//  JFValidator.h
//  JFramework
//
//  Created by Denis Jajčević on 03.11.2013..
//  Copyright (c) 2013. Denis Jajčević. All rights reserved.
//

#import "JFObject.h"

#import "NSObject+Shortcuts.h"

// Used to add an additional property validation keys to property metada
FOUNDATION_EXPORT_DECLARATION(JFValidationKey)
FOUNDATION_EXPORT_DECLARATION(JFValidationNotNullKey)
FOUNDATION_EXPORT_DECLARATION(JFValidationNotEmptyKey)
FOUNDATION_EXPORT_DECLARATION(JFValidationRegexKey)
FOUNDATION_EXPORT_DECLARATION(JFValidationEmailKey)

/**
 Validator is ment to ease validation process. It is embeded with JFObject class.
 There are preconfigured public validators, such as:
 +JFNotNullValidator,
 +JFNotEmptyValidator,
 +JFEmailValidator,
 +JFRegexValidator,

 @see JFObject
 */
@class JFValidator;

typedef BOOL (^JFValidationBlock)(JFValidator *validator, id value);

@interface JFValidator : NSObject

-(id) initWithKey:(NSString*) key andValidationBlock:(JFValidationBlock) block;
-(id) initWithKey:(NSString*) key controlValue:(id) controlValue andValidationBlock:(JFValidationBlock) block;

/// a unique key to identify validator
@property (strong, nonatomic) NSString *key;
/// a value that validator uses for detailed validation. Usually used for regex and explicit checks.
@property (strong, nonatomic) id value;
/// a block that performs actual validation
@property (copy, nonatomic) JFValidationBlock validationBlock;

-(BOOL) validateValue:(id) value;

+(JFValidator*) JFNotNullValidator;
+(JFValidator*) JFNotEmptyValidator;
+(JFValidator*) JFEmailValidator;
+(JFValidator*) JFRegexValidator;
+(JFValidator*) JFExactNumberValidator:(NSNumber*) number;
+(JFValidator*) JFExactStringValidator:(NSString*) string;

@end