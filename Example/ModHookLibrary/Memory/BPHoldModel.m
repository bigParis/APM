//
//  BPHoldModel.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/12/1.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPHoldModel.h"
#import "BPLeakModelManager.h"

@implementation BPHoldModel
- (void)dealloc
{
    NSLog(@"%s", __func__);
    [[BPLeakModelManager sharedManager] unRegisterModel:NSStringFromClass(self.class)];
}

- (instancetype)init
{
    if (self = [super init]) {
        [[BPLeakModelManager sharedManager] registerModel:self forKey:NSStringFromClass(self.class)];
    }
    return self;
}
@end
