//
//  NSObject+Shortcuts.m
//  JFramework
//
//  Created by Denis Jajčević on 03.11.2013..
//  Copyright (c) 2013. Denis Jajčević. All rights reserved.
//

#import "NSObject+Shortcuts.h"

@implementation NSObject (Shortcuts)

-(ApplicationDelegateClass*)appDelegate
{
    return (ApplicationDelegateClass*)[[UIApplication sharedApplication] delegate];
}

@end
