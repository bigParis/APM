//
//  NSMutableArray+hook.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/7/12.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "NSMutableArray+hook.h"
#import <objc/runtime.h>
#import "NSObject+DataRaceScaner.h"

@implementation NSMutableArray (hook)

+ (void)startHook
{    
    Class __NSArrayM = objc_getClass("__NSArrayM");
    DRS_SWIZZLELOGIC(__NSArrayM, objectAtIndex:);
    DRS_SWIZZLELOGIC(__NSArrayM, addObject:);
}

- (id)drs_objectAtIndex:(NSUInteger)index
{
    DRS_READLOGINC(nil, [self drs_objectAtIndex:index]);
}

- (void)drs_addObject:(id)anObject
{
    DRS_WRITELOGIC([self drs_addObject:anObject]);
}
@end
