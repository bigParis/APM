//
//  BPLeakShowView.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/12/1.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPLeakShowView.h"
#import "BPLeakModelManager.h"

@implementation BPLeakShowView
- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.yellowColor;
    }
    return self;
}

- (void)testLeak
{
    if (self.leakBlock) {
        self.leakBlock();
    }
}
@end
