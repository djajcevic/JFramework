//
//  NSDictionary+JF.m
//  Hattrick
//
//  Created by Denis Jajčević on 12/15/12.
//  Copyright (c) 2012 JF. All rights reserved.
//

#import "NSDictionary+JF.h"
//#import "JFModel.h"

@implementation NSDictionary (JF)

+ (id)dictionaryOrArrayWithContentsOfDictionaryData:(NSData *)data
{
    CFStringRef error;
//    NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    CFPropertyListRef plist = CFPropertyListCreateFromXMLData (kCFAllocatorSystemDefault, CFDataCreate (nil, [data bytes], [data length]), kCFPropertyListImmutable, &error);
    if ([(__bridge id) plist isKindOfClass:[NSDictionary class]]) {
        return (__bridge_transfer NSDictionary *) plist;
    }
    else if ([(__bridge id) plist isKindOfClass:[NSArray class]]) {
        return (__bridge_transfer NSArray *) plist;
    }
    else if (error != nil) {
        NSLog (@"ISKON: ERROR WHILE CONVERTING NSDATA TO NSDICTIONARY/NSARRAY: %@", error);
        CFRelease (error);
        return nil;
    } else {
        CFRelease (plist);
        return nil;
    }
}

//- (id)objectOfClass:(Class)clazz
//{
//    id object = [clazz new];
//
//    id    value = nil;
//    Class clazzz;
//
//    for (NSString *key in self.allKeys) {
//        value = [self valueForKey:key];
//        if ([value isKindOfClass:[NSArray class]]) {
//            JFMutableArray *array = [object valueForKey:key];
//            Class   itemsClass = array.itemsClass;
//            for (id element in value) {
//                [array addObject:[element objectOfClass:itemsClass]];
//            }
//        }
//        else if ([value isKindOfClass:[NSDictionary class]]) {
//            clazzz = [[object valueForKey:key] class];
//            id innerObject = [value objectOfClass:clazzz];
//            [object setValue:innerObject forPropertyName:key];
//        }
//        else {
//            [object setValue:value forPropertyName:key];
//        }
//    }
//
//    return object;
//}

//- (id)JFModelOfClass:(Class)clazz
//{
//    JFModel *object = [clazz new];
//
//    if ([object respondsToSelector:@selector(setDictionaryRepresentation:)]) {
//        [object setDictionaryRepresentation:[NSMutableDictionary dictionaryWithDictionary:self]];
//    }
//
//    id    value = nil;
//    Class clazzz;
//
//    for (NSString *key in self.allKeys) {
//        if ([clazz doesIgnorePropertyNamed:key])
//            continue;
//        value = [self valueForKey:key];
//        if ([value isKindOfClass:[NSArray class]]) {
//            JFMutableArray *array = [object valueForKey:key];
//            Class   itemsClass = array.itemsClass;
//            for (id element in value) {
//                [array addObject:[element JFModelOfClass:itemsClass]];
//            }
//        }
//        else if ([value isKindOfClass:[NSDictionary class]]) {
//            id innerObject = nil;
//            clazzz         = [[object valueForKey:key] class];
//            if (clazzz == nil && [object respondsToSelector:@selector(classForPropertyNamed:)]) {
//                clazzz = [object classForPropertyNamed:key];
//                if (clazzz == nil) {
//                    DebugBlock (^{
//                        NSLog (@"ISKON: I do not know the class for property '%@' of class '%@'. Implement 'classForPropertyNamed:' method in your model.", key, NSStringFromClass (clazz));
//                    });
//                    continue;
//                }
//                innerObject = [value JFModelOfClass:clazzz];
//            }
//            else {
//                innerObject = value;
//            }
//            [object setValue:innerObject forPropertyName:key];
//        }
//        else {
//            [object setValue:value forPropertyName:key];
//        }
//    }
//
//    [object afterPropertiesSet];
//
//    return object;
//}

//-(id)coreDataModelWithEntityDescription:(NSEntityDescription *)entity andModelClass:(__unsafe_unretained Class)clazz inContext:(NSManagedObjectContext *)context
//{
//    NSManagedObject *object = [[clazz alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
//    
//    if ([object respondsToSelector:@selector(setDictionaryRepresentation:)]) {
//        [object setDictionaryRepresentation:[NSMutableDictionary dictionaryWithDictionary:self]];
//    }
//
//    id value = nil;
//
//    for (NSString *key in self.allKeys) {
//        if ([clazz doesIgnorePropertyNamed:key])
//            continue;
//        value = [self valueForKey:key];
//        if ([value isKindOfClass:[NSArray class]]) {
//            id<JFDomainModelMapper> mapper = [self.appDelegate.mapperMapping[NSStringFromClass(clazz)] new];
//            if (mapper == nil) {
//                mapper = [self.appDelegate.mapperMapping[[NSStringFromClass(clazz) stringByAppendingFormat:@".%@", key]] new];
//            }
//
//            if (mapper != nil) {
//                [mapper mapArrayProperty:value named:key toModel:object inContext:context];
//                continue;
//            }
//            [object setValue:value forPropertyName:key];
//        }
//        else if ([value isKindOfClass:[NSDictionary class]]) {
//            id<JFDomainModelMapper> mapper = mapper = [self.appDelegate.mapperMapping[NSStringFromClass(clazz)] new];
//            if (mapper == nil) {
//                mapper = [self.appDelegate.mapperMapping[[NSStringFromClass(clazz) stringByAppendingFormat:@".%@", key]] new];
//            }
//            if (mapper != nil) {
//                [mapper mapDictionaryProperty:value named:key toModel:object inContext:context];
//                continue;
//            }
//            [object setValue:value forPropertyName:key];
//        }
//        else {
//            [object setValue:value forPropertyName:key];
//        }
//    }
//
//    return object;
//
//}

- (void)mapToInstance:(id)instance
{
    for (NSString *propertyName in self) {
        id value = [self objectForKey:propertyName];
        if (![value isKindOfClass:[NSDictionary class]]) {
            [instance setValue:value forKeyPath:propertyName];
        }
    }
}

@end
