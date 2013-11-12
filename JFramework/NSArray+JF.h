//
//  NSArray+JF.h
//  Hattrick
//
//  Created by Denis Jajčević on 12/16/12.
//  Copyright (c) 2012 JF. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    INT,
    FLOAT,
    STRING
} NSArrayItemClasses;

@interface NSArray (JF)

- (NSArray *)objectsOfClass:(Class)clazz;

- (NSArray *)JFModelsOfClass:(Class)clazz;

- (BOOL)empty;

- (void)makeObjectsPerformDescriptionSelector:(SEL)aSelector;

- (NSArray *)itemClasses;

@end
