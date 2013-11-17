//
//  NSObject+Shortcuts.h
//  JFramework
//
//  Created by Denis Jajčević on 03.11.2013..
//  Copyright (c) 2013. Denis Jajčević. All rights reserved.
//

#import <Foundation/Foundation.h>

// define ApplicationDelegateClass with your application delegate class with import, and remove header import at your app delegate's class implementation in pch file...

#define FOUNDATION_EXPORT_DECLARATION(name) FOUNDATION_EXPORT NSString *const (name);
#define FOUNDATION_EXPORT_VALUE(name, value) NSString *const (name) = (value);


@interface NSObject (Shortcuts)

-(ApplicationDelegateClass*) appDelegate;

@end
