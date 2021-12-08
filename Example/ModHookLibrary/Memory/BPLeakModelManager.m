//
//  BPLeakModelManager.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/12/1.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPLeakModelManager.h"

@interface BPLeakModelManager()
@property (nonatomic, strong) NSMutableDictionary *modelMap;
@end
@implementation BPLeakModelManager
+ (instancetype)sharedManager
{
    static BPLeakModelManager *instance = nil;
    if (!instance)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[BPLeakModelManager alloc] init];
        });
    }
    return instance;
}

- (void)registerModel:(id)model forKey:(NSString *)aKay
{
    if (model) {
        [self.modelMap setObject:model forKey:aKay];
    }
}

- (void)unRegisterModel:(NSString *)aKey
{
    if (aKey) {
        [self.modelMap removeObjectForKey:aKey];
    }
}

- (id)getModelForKey:(NSString *)aKey
{
    return [self.modelMap objectForKey:aKey];
}

- (NSMutableDictionary *)modelMap
{
    if (_modelMap == nil) {
        _modelMap = [NSMutableDictionary dictionary];
    }
    return _modelMap;
}
@end
