//
//  BPContainer.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/12/9.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPContainer.h"
#import "BPLeakModel.h"

@interface BPContainer ()
@property (nonatomic, strong) NSMutableArray *models;
@end
@implementation BPContainer
- (void)dealloc
{
    NSLog(@"--BPContainer dealloc--");
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _models = @[].mutableCopy;

    }
    return self;
}

- (void)addModel:(BPLeakModel *)model
{
    if (!model) return;
    [self.models addObject:model];
}

- (BPLeakModel *)takeModel
{
//    NSMutableArray *toOperateArray = self.models;
    for (BPLeakModel *model in self.models) {
        NSLog(@"model:%@, thread:%@", model, [NSThread currentThread]);
    }

    BPLeakModel *model = [self.models firstObject];
    [self.models removeObject:model];

    return model;
}
@end
