//
//  BPLeakHoldView.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/12/1.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPLeakHoldView.h"
#import "BPLeakModel.h"
#import "BPLeakModelManager.h"
@interface BPLeakHoldView()
//@property (nonatomic, strong) BPLeakModel *leakModel;
@end
@implementation BPLeakHoldView
- (void)dealloc
{
    NSLog(@"%s", __func__);
    [[BPLeakModelManager sharedManager] unRegisterModel:NSStringFromClass(self.class)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
//        _leakModel = [[BPLeakModel alloc] init];
//        _leakModel.modelName = @"BPLeakModel";
        self.backgroundColor = UIColor.redColor;
        [[BPLeakModelManager sharedManager] registerModel:self forKey:NSStringFromClass(self.class)];
    }
    return self;
}

- (NSString *)name
{
    return @"BPLeakHoldView";
}

@end
