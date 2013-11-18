//
//  JFObjectMeta.h
//  Iskon
//
//  Created by Denis Jajčević on 16.9.2013..
//  Copyright (c) 2013. JajcevicFramework. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "objc/runtime.h"
#import "NSArray+JF.h"
#import "NSDictionary+JF.h"

@interface JFObjectMeta : NSObject

@property (assign, nonatomic) Class clazz;
@property (strong, nonatomic) NSArray *propertyNames;
@property (strong, nonatomic) NSArray *propertyClasses;
@property (strong, nonatomic) NSDictionary *propertyAttributes;

- (id)initWithClass:(Class)clazz;
-(Class) classForPropertyNamed:(NSString *)propertyName;

@end
