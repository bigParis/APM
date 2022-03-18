//
//  BPRuntimeExcutor.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/3/2.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "BPRuntimeExcutor.h"

@implementation BPRuntimeExcutor
- (void)scrollToIndex:(NSUInteger)index animation:(BOOL)animation
{
    NSLog(@"index:%@, animation:%@", @(index), @(animation));
}
@end
