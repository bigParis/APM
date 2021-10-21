//
//  BPPointArrayMgr.m
//  ModHookLibrary_Example
//
//  Created by 王飞 on 2021/10/21.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPPointArrayMgr.h"

@interface BPPointArrayMgr()

@property (nonatomic, strong) NSMutableArray *testArray;
@property (nonatomic, strong) NSPointerArray *pointerArray;

@end

@implementation BPPointArrayMgr
+ (instancetype)sharedManager
{
    static BPPointArrayMgr *instance = nil;
    if (!instance)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[BPPointArrayMgr alloc] init];
        });
    }
    return instance;
}

- (NSString *)addPointer:(id<IBPPointerProtocol>)pointer
{
    NSLog(@"--addPointer:%@", pointer.pointerName);
    [self.pointerArray addPointer:(__bridge void * _Nullable)(pointer)];
    return pointer.pointerName;
}

- (void)removePointer:(NSString *)pointerId
{
    for (int i = 0; i < self.pointerArray.count; ++i) {
        id<IBPPointerProtocol> point = [self.pointerArray pointerAtIndex:i];
        if (pointerId && [point.pointerName isEqualToString:pointerId]) {
            [self.pointerArray removePointerAtIndex:i];
            NSLog(@"remove pointer:%@", pointerId);
            break;
        }
    }
}

- (void)removePointers:(NSArray *)pointerIds
{
    for (int i = 0; i < self.pointerArray.count; ++i) {
        id<IBPPointerProtocol> point = [self.pointerArray pointerAtIndex:i];
        if (point && point.pointerName && [pointerIds containsObject:point.pointerName]) {
            [self.pointerArray removePointerAtIndex:i];
            NSLog(@"remove pointer:%@", point.pointerName);
        } else {
            NSLog(@"no need to remove pointer at index:%@", @(i));
        }
    }
}

- (void)testCompact
{
    NSLog(@"===before compact===");
    [self printPointer];
    [self.pointerArray addPointer:NULL];
    [self.pointerArray compact];
    NSLog(@"===after compact===");
    [self printPointer];
}

- (void)printPointer
{
    NSArray *pointerArray = self.pointerArray.allObjects;
    NSLog(@"pointerArray.allObjects.count:%@", @(pointerArray.count));
    NSLog(@"pointerArray.count:%@", @(self.pointerArray.count));
    for (id<IBPPointerProtocol> pointer in self.pointerArray) {
        NSLog(@"pointer:%@", pointer.pointerName);
    }
}
- (NSMutableArray *)testArray
{
    if (_testArray == nil) {
        _testArray = [NSMutableArray array];
    }
    return _testArray;
}

- (NSPointerArray *)pointerArray
{
    if (_pointerArray == nil) {
        _pointerArray = [NSPointerArray weakObjectsPointerArray];
    }
    return _pointerArray;
}
@end
