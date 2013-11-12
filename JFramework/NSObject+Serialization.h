//
//  NSObject+Serialization.h
//  JFramework
//
//  Created by Denis Jajčević on 31.10.2013..
//  Copyright (c) 2013. Denis Jajčević. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSerializationPropertyArrayItemsClassKey @"SerializationPropertyArrayItemsClassKey"

#import "JFObjectMeta.h"
@class JFObject;

@interface NSObject (Serialization)

-(JFObjectMeta *)metaData;

-(NSDictionary*) toDictionary;
+(NSArray*) toDictionaryArray:(NSArray*) array;
-(NSData*) toJson;
+(NSData*) toJsonArray:(NSArray*) array;
-(NSString*) toJsonString;
+(NSString*) toJsonArrayString:(NSArray*) array;

+(instancetype) fromDictionary:(NSDictionary*) dictionary;
+(NSArray*) fromDictionaryArray:(NSArray*) dictionaryArray;
+(instancetype) fromJson:(NSData*) data;
+(NSArray*) fromJsonArray:(NSData*) data;
+(instancetype) fromJsonString:(NSString*) string;
+(NSArray*) fromJsonArrayString:(NSString*) string;

@property (readonly, nonatomic) NSArray *ignoredSerializationFields;

@end
