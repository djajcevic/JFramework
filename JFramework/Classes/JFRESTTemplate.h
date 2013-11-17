//
//  JFRESTTemplate.h
//  JFUtilNetwork
//
//  Created by Denis Jajčević on 1.3.2013..
//  Copyright (c) 2013. JajcevicFramework. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JFRESTTemplate : NSObject <NSCopying>

@property (nonatomic, copy) NSString                *requestDomain;
@property (nonatomic, readonly) NSString            *requestTemplate;
@property (nonatomic, readonly) NSArray             *requestParameters;
@property (nonatomic, readonly) NSMutableDictionary *requestParametersAndValues;

- (void)setValue:(id)value forKey:(NSString *)key;

- initWithRequestTemplate:(NSString *)requestTemplate;

- (NSString *)preparedRequest;

- (NSURLRequest *)preparedURLRequest;

@end
