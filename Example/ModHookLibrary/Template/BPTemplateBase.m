//
//  BPTemplateBase.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/10/28.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPTemplateBase.h"

@implementation BPTemplateBase
- (instancetype)init
{
    if (self = [super init]) {
        [self openTheDoor];
        [self getInTheCar];
        [self driveTheCar];
    }
    return self;
}

- (void)openTheDoor
{
    NSLog(@"base openTheDoor");
}

- (void)getInTheCar
{
    NSLog(@"base getInTheCar");
}

- (void)driveTheCar
{
    NSLog(@"base driveTheCar");
}
@end
