//
//  NSMutableURLRequest+JF.h
//  JFUtilNetwork
//
//  Created by Denis Jajčević on 28.2.2013..
//  Copyright (c) 2013. JajcevicFramework. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (JF)

+ (NSMutableURLRequest *)postRequestWithUrl:(NSString *)url headerAtt:(NSDictionary *)headerAtt andBodyAtt:(NSDictionary *)bodyAttr;

+ (NSMutableURLRequest *)post:(NSString *)url;
+ (NSMutableURLRequest *)get:(NSString*)url;
+( NSMutableURLRequest *)getWithPathValues:(NSString *)urlFormat, ...;

- (NSMutableURLRequest *)body:(NSDictionary *)attr;
- (NSMutableURLRequest *)jsonBody:(NSDictionary *)attr;


- (NSMutableURLRequest *)headers:(NSDictionary *)attr;

- (NSMutableURLRequest *)setTimeoutInSec:(int) timeout;

@end
