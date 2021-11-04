//
//  BPMultiThreadSafeObject.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/11/1.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPMultiThreadSafeObject.h"

@interface BPMultiThreadSafeObject ()

@property (nonatomic, strong) dispatch_queue_t workQueue;

@end

@implementation BPMultiThreadSafeObject

- (instancetype)init
{
    if (self = [super init]) {
        _workQueue = dispatch_queue_create("com.bpmultithread.workqueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)dealloc
{
    _workQueue = nil;
    _mtsContainer = nil;
}

- (NSString *)description
{
    return _mtsContainer.description;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [[_mtsContainer class] instanceMethodSignatureForSelector:aSelector];
//    return  [_mtsContainer methodSignatureForSelector:aSelector];
}

+ (NSMethodSignature *)instanceMethodSignatureForSelector:(SEL)aSelector
{
    return [NSMutableArray instanceMethodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSMethodSignature *sig = [anInvocation valueForKey:@"_signature"];
    
    const char *returnType = sig.methodReturnType;
    
    if (!strcmp(returnType, "v")) {
        dispatch_barrier_async(_workQueue, ^{
            [anInvocation invokeWithTarget:_mtsContainer];
        });
    } else {
        dispatch_barrier_sync(_workQueue, ^{
            [anInvocation invokeWithTarget:_mtsContainer];
        });
    }
}
@end
