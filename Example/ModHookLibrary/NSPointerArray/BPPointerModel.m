//
//  BPPointerModel.m
//  ModHookLibrary_Example
//
//  Created by 王飞 on 2021/10/21.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPPointerModel.h"

@interface BPPointerModel()

@end

@implementation BPPointerModel
- (void)dealloc
{
    NSLog(@"--dealloc BPPointerModel:%@", _name);
}

- (NSString *)pointerName
{
    return _name;
}
@end
