//
//  JFRESTService.h
//  JFUtilNetwork
//
//  Created by Denis Jajčević on 1.3.2013..
//  Copyright (c) 2013. JajcevicFramework. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JFRESTTemplate.h"

@interface JFRESTService : NSObject

@property (nonatomic, copy) NSString              *domain;
@property (nonatomic, retain) NSMutableDictionary *requests;

- initWithDomain:(NSString *)domain;

- (void)registerRequest:(NSString *)request forName:(NSString *)name;

- (NSString *)preparedRequest:(NSString *)requestName withParameter:(id)parameter, ...;

- (NSURLRequest *)preparedURLRequest:(NSString *)requestName withParameter:(id)parameter, ...;

@end
