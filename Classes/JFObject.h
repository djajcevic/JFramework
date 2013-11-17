//
//  JFObject.h
//  JFramework
//
//  Created by Denis Jajčević on 31.10.2013..
//  Copyright (c) 2013. Denis Jajčević. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSerializationPropertyArrayItemsClassKey @"SerializationPropertyArrayItemsClassKey"

#import "NSString+JF.h"
#import "JFObjectMeta.h"
#import "JFValidator.h"
#import "JFSerializableProtocol.h"


#pragma mark - interface

@interface JFObject : NSObject <JFSerializableProtocol>

@property (strong, nonatomic) NSMutableDictionary *dictionary;
+(JFObjectMeta *) metaData;
-(JFObjectMeta *) metaData;
-(BOOL) valid;

@property (readonly, nonatomic) NSArray *ignoredSerializationFields;

@end
