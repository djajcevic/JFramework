//
//  NSObject+Shortcuts.h
//  JFramework
//
//  Created by Denis Jajčević on 03.11.2013..
//  Copyright (c) 2013. Denis Jajčević. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FOUNDATION_EXPORT_DECLARATION(name) FOUNDATION_EXPORT NSString *const (name);
#define FOUNDATION_EXPORT_VALUE(name, value) NSString *const (name) = (value);


@interface NSObject (Shortcuts)

@end
