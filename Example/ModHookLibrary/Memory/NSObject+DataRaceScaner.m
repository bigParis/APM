//
//  NSObject+DataRaceScaner.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/7/12.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "NSObject+DataRaceScaner.h"
#import <objc/runtime.h>
#include <os/lock.h>
#include <pthread.h>

static BOOL isWarning = NO;
static DataRaceScanerCallBack reportCallback = nil;

void YYCG_ISSwizzleInstanceMethod(Class className, SEL originalSelector, SEL alternativeSelector)
{
    Method originalMethod = class_getInstanceMethod(className, originalSelector);
    Method alternativeMethod = class_getInstanceMethod(className, alternativeSelector);
    
    if (class_addMethod(className,
                        originalSelector,
                        method_getImplementation(alternativeMethod),
                        method_getTypeEncoding(alternativeMethod)))
    {
        class_replaceMethod(className,
                            alternativeSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, alternativeMethod);
    }
}

void DRS_ISSwizzleInstanceMethod(Class className, SEL originalSelector, SEL alternativeSelector)
{
    YYCG_ISSwizzleInstanceMethod(className, originalSelector, alternativeSelector);
}

static NSNumber * GetCurrentThreadId()
{
    mach_port_t machTID = pthread_mach_thread_np(pthread_self());
    return @(machTID);
}

BOOL DRS_JudgeIfDataRace(NSNumber *thread)
{
    return nil != thread && ![thread isEqualToValue:GetCurrentThreadId()];
}

void DRS_ReportDataRace(NSString *error, NSNumber *writeThread)
{
    if (isWarning) {
        return;
    }
    isWarning = YES;
    NSString *currentStack = [NSThread callStackSymbols].description;
    NSString *stack = [NSString stringWithFormat:@"current:%@、write:%@\n%@", writeThread, GetCurrentThreadId(), currentStack];
    NSString *abnormalMsg = [NSString stringWithFormat:@"%@\n%@", error, stack];

//    BOOL shouldReport = !reportCallback || reportCallback(error, stack);
//    if (shouldReport) {
//        YYCGSafeBlock(YYCrashGuard.reportCallback, abnormalMsg, YYCrashGuardReportType_DataRace);
//    }
    
    if ([NSThread isMainThread]) {
        isWarning = NO;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            isWarning = NO;
        });
    }
}
@implementation NSObject (DataRaceScaner)
#pragma mark - unfairlock
- (void)setDrs_unfairLock:(drs_os_unfair_lock_t)lock
{
    NSData *data = [NSData dataWithBytes:&lock length:sizeof(lock)];
    objc_setAssociatedObject(self, @selector(drs_unfairLock), data, OBJC_ASSOCIATION_RETAIN);
}

- (drs_os_unfair_lock_t)drs_unfairLock
{
    drs_os_unfair_lock_t lock;
    if (!objc_getAssociatedObject(self, @selector(drs_unfairLock))) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        os_unfair_lock_t ll = (os_unfair_lock_t)(&lock);
        *ll = (os_unfair_lock){0};
#pragma clang diagnostic pop
        [self setDrs_unfairLock:lock];
        return lock;
    }
    NSData *data = objc_getAssociatedObject(self, @selector(drs_unfairLock));
    [data getBytes:&lock length:sizeof(lock)];
    return lock;
}
#pragma mark - thread
- (void)setDrs_thread:(NSNumber *)drs_thread
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    drs_os_unfair_lock_t lock = self.drs_unfairLock;
    os_unfair_lock_lock((os_unfair_lock_t)(&lock));
    objc_setAssociatedObject(self, @selector(drs_thread), drs_thread, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    os_unfair_lock_unlock((os_unfair_lock_t)(&lock));
#pragma clang diagnostic pop
}

- (NSNumber *)drs_thread
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    drs_os_unfair_lock_t lock = self.drs_unfairLock;
    os_unfair_lock_lock((os_unfair_lock_t)(&lock));
    NSNumber *thread = objc_getAssociatedObject(self, @selector(drs_thread));
    os_unfair_lock_unlock((os_unfair_lock_t)(&lock));
#pragma clang diagnostic pop
    return thread;
}

- (void)drs_startWritingCompletion:(dispatch_block_t)block
{
    self.drs_thread = GetCurrentThreadId();
    if (block) {
         block();
    }
    self.drs_thread = nil;
}
@end
