//
//  BPTimerMonitor.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/5/12.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "BPTimerMonitor.h"

@interface BPTimerMonitor()

@property (nonatomic, strong) NSMutableDictionary *timersDict;

@end
@implementation BPTimerMonitor
+ (instancetype)sharedManager
{
    static BPTimerMonitor *instance = nil;
    if (!instance)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[BPTimerMonitor alloc] init];
        });
    }
    return instance;
}

- (void)addTimer:(NSTimer *)timer block:(void (^)(NSTimer * _Nonnull))block
{
    NSString *key = [NSString stringWithFormat:@"%p", timer];
    NSString *blockString = [NSString stringWithFormat:@"%@", block];
    NSString *targetString = NSStringFromClass([timer class]);
    NSDictionary *valueDict = @{@"target" : targetString, @"block" : blockString};
    self.timersDict[key] = valueDict;
    NSLog(@"YYTimerMonitor:addTimer:dict:%@", self.timersDict);
}

- (void)addTimer:(NSTimer *)timer aSelector:(SEL)aSelector
{
    NSString *key = [NSString stringWithFormat:@"%p", timer];
    NSString *targetString = NSStringFromClass([timer class]);
    NSString *selString = NSStringFromSelector(aSelector);
    NSDictionary *valueDict = @{@"target" : targetString, @"selector" : selString};
    self.timersDict[key] = valueDict;
    NSLog(@"YYTimerMonitor:addTimer:dict:%@", self.timersDict);
}

- (void)removeTimer:(NSTimer *)timer
{
    NSString *key = [NSString stringWithFormat:@"%p", timer];
    [self.timersDict removeObjectForKey:key];
    NSLog(@"YYTimerMonitor:removeTimer:dict:%@", self.timersDict);
}

- (NSMutableDictionary *)timersDict
{
    if (_timersDict == nil) {
        _timersDict = [NSMutableDictionary dictionary];
    }
    return _timersDict;
}

@end
