//
//  BPLeakModel.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/12/1.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPLeakModel.h"
#import "BPHoldModel.h"
#import "BPLeakModelManager.h"

@interface BPLeakModel()
@property (nonatomic, strong) BPHoldModel *holdModel;
@property (nonatomic, strong) UIView *view;
@end

@implementation BPLeakModel
- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (instancetype)initWithView:(UIView *)view
{
    if (self = [super init]) {
        _view = view;
        _holdModel = [[BPHoldModel alloc] init];
        _holdModel.holderName = @"leakModel";
//        _holdModel.holdView = view;
//        [[BPLeakModelManager sharedManager] registerModel:self forKey:NSStringFromClass(self.class)];
    }
    return self;
}

- (void)testLeak
{
    if (self.leakBlock) {
        self.leakBlock();
    }
}

- (NSDictionary *)leakMap
{
    return @{@"leak1" : self.holdModel};
}
@end
