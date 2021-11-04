//
//  BPMutableArray.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/11/1.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPMutableArray.h"

@implementation BPMutableArray

- (instancetype)init
{
    if (self = [super init]) {
        self.mtsContainer = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)array
{
    return [[self alloc] init];
}
@end
