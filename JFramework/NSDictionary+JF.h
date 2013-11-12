//
//  NSDictionary+JF.h
//  Hattrick
//
//  Created by Denis Jajčević on 12/15/12.
//  Copyright (c) 2012 JF. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "NSObject+JF.h"
//#import "JFUtils.h"

#import <CoreData/CoreData.h>

@class JFMutableArray;
@class JFModel;

@interface NSDictionary (JF)

+ (id)dictionaryOrArrayWithContentsOfDictionaryData:(NSData *)data;

- (id)objectOfClass:(Class)clazz;

- (id)JFModelOfClass:(Class)clazz;
//-(id) coreDataModelWithEntityDescription:(NSEntityDescription*) entity andModelClass:(Class) clazz inContext:(NSManagedObjectContext*) context;

- (void)mapToInstance:(id)instance;


@end
