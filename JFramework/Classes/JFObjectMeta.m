//
//  JFObjectMeta.m
//  Iskon
//
//  Created by Denis Jajčević on 16.9.2013..
//  Copyright (c) 2013. CROZ. All rights reserved.
//

#import "JFObjectMeta.h"

@implementation JFObjectMeta

- (id)initWithClass:(Class)clazz
{
    self = [super init];
    if (self) {
        self.clazz = clazz;
        u_int count;


        NSMutableArray  *propertyArray   = [NSMutableArray array];
        NSMutableArray  *propertyClasses = [NSMutableArray array];
//        while (currentClass != [NSObject class] && ![currentClass isSubclassOfClass:[NSNumber class]] && ![currentClass isSubclassOfClass:[NSArray class]]
//               && ![currentClass isSubclassOfClass:[NSDictionary class]] && ![currentClass isSubclassOfClass:[NSString class]] && ![currentClass isSubclassOfClass:[NSSet class]]) {
//            objc_property_t *properties      = class_copyPropertyList (self.clazz, &count);
//            for (int i = 0; i < count; i++) {
//                const char *propertyName = property_getName (properties[i]);
//                const char *className    = property_copyAttributeValue (properties[i], "T");
//                [propertyArray addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
//                [propertyClasses addObject:[NSString stringWithCString:className encoding:NSUTF8StringEncoding]];
//
//            }
//            free (properties);
//
//        }
        Class currentClass = clazz;
        while ([self validClass:currentClass]) {
            [self populatePropertyNames:propertyArray andPropertyClasses:propertyClasses forClass:currentClass];
            currentClass = [currentClass superclass];
        }
        self.propertyNames   = propertyArray;
        self.propertyClasses = [propertyClasses itemClasses];
    }
    return self;
}

-(void) populatePropertyNames:(NSMutableArray*) propertyArray andPropertyClasses:(NSMutableArray*) propertyClasses forClass:(Class) clazz
{
    u_int count;

    objc_property_t *properties      = class_copyPropertyList (clazz, &count);
    for (int i = 0; i < count; i++) {
        const char *propertyName = property_getName (properties[i]);
        const char *className    = property_copyAttributeValue (properties[i], "T");
        NSString *classNameString = [[NSString alloc] initWithCString:className encoding:NSUTF8StringEncoding];
        if ([classNameString isEqualToString:@"c"]) {
            classNameString = @"NSNumber";
        }
        else if ([classNameString length] == 1) {
            classNameString = nil;
        }
        else {
            NSString *className = [classNameString substringWithRange:(NSRange) {2, classNameString.length - 3}];
            classNameString = className;
        }

        if (className != nil) {
            [propertyArray addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
            [propertyClasses addObject:classNameString];
        }

    }
    free (properties);
}

-(BOOL) validClass:(Class) clazz
{
    return clazz != nil && clazz != [NSObject class] && ![clazz isSubclassOfClass:[NSNumber class]] && ![clazz isSubclassOfClass:[NSArray class]]
    && ![clazz isSubclassOfClass:[NSDictionary class]] && ![clazz isSubclassOfClass:[NSString class]] && ![clazz isSubclassOfClass:[NSSet class]];
}

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString string];

    int index = 0;
    for (NSString *propertyName in self.propertyNames) {
        [desc appendFormat:@"\n\t%@ : %@", propertyName, self.propertyClasses[index]];
        index++;
    }

    return desc;
}

-(Class) classForPropertyNamed:(NSString *)propertyName
{
    int index = [self.propertyNames indexOfObject:propertyName];
    if (index != NSNotFound)
        return self.propertyClasses[index];
    else
        return nil;
}

@end
