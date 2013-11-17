//
//  NSArray+JF.m
//  Hattrick
//
//  Created by Denis Jajčević on 12/16/12.
//  Copyright (c) 2012 JF. All rights reserved.
//

@implementation NSArray (JF)

//- (NSArray *)objectsOfClass:(Class)clazz
//{
//    if (self.count == 0)
//        return nil;
//
//    NSMutableArray *array = [NSMutableArray array];
//
//    for (id object in self) {
//
//        if ([object isKindOfClass:[NSDictionary class]]) {
//            NSDictionary *dict = (NSDictionary *) object;
//            id object = [dict objectOfClass:clazz];
//            [array addObject:object];
//        }
//
//    }
//
//    return [NSArray arrayWithArray:array];
//}
//
//- (NSArray *)JFModelsOfClass:(Class)clazz
//{
//    if (self.count == 0)
//        return nil;
//
//    NSMutableArray *array = [NSMutableArray array];
//
//    for (id object in self) {
//
//        if ([object isKindOfClass:[NSDictionary class]]) {
//            NSDictionary *dict = (NSDictionary *) object;
//            id object = [dict JFModelOfClass:clazz];
//            [array addObject:object];
//
//        }
//
//    }
//
//    return [NSArray arrayWithArray:array];
//}
//
//static NSString *valueInStringWithFormat(id value, NSString *format, NSArrayItemClasses castToClazz) {
//    switch (castToClazz) {
//        case INT:
//            return [NSString stringWithFormat:format, [value intValue]];
//        case FLOAT:
//            return [NSString stringWithFormat:format, [value doubleValue]];
//        case STRING:
//            return [NSString stringWithFormat:format, value];
//    }
//}
//
//- (BOOL)empty
//{
//    return self.count == 0;
//}
//
//- (void)makeObjectsPerformDescriptionSelector:(SEL)aSelector
//{
//    for (NSObject *item in self) {
//        [item descriptionWithSelector:aSelector];
//    }
//}

- (NSArray *)itemClasses
{
    NSMutableArray *classes = [NSMutableArray arrayWithCapacity:self.count];

    if (self.count) {
        if ([self[0] isKindOfClass:[NSString class]]) {
            for (NSString *item in self) {
//                if ([item isEqualToString:@"c"]) {
//                    [classes addObject:[NSNumber class]];
//                }
//                else if ([item length] == 1) {
//                    continue;
//                }
//                else {
//                    NSString *itemValue = [item substringWithRange:(NSRange) {2, item.length - 3}];
//                }
                [classes addObject:NSClassFromString (item)];
            }
        }
        else {
            for (NSObject *item in self) {
                [classes addObject:[item class]];
            }
        }
    }
    return classes;
}

@end
