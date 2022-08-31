//
//  NSObject+DataRaceScaner.h
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/7/12.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef struct drs_os_unfair_lock_s {
    uint32_t _drs_os_unfair_lock_opaque;
} drs_os_unfair_lock_t;

#define DRS_WEAKIFY(obj) \
__weak __typeof__(obj) obj##_weak_ = obj;

#define DRS_STRONGIFY(obj) \
__strong __typeof__(obj##_weak_) obj = obj##_weak_;

#define DRS_SWIZZLELOGIC(_class, _selStr) \
DRS_ISSwizzleInstanceMethod(_class, @selector(_selStr), @selector(drs_##_selStr));

#define DRS_WRITELOGIC(method) \
NSNumber* drsThread = self.drs_thread; \
if (DRS_JudgeIfDataRace(drsThread)) { DRS_REPORTRACE(drsThread) return; } DRS_WRITING(method);

#define DRS_WRITING(method)  \
DRS_WEAKIFY(self)[self drs_startWritingCompletion:^{DRS_STRONGIFY(self) method;}]; \

#define DRS_READLOGINC(default, method) \
NSNumber* drsThread = self.drs_thread; \
if (DRS_JudgeIfDataRace(drsThread)) { DRS_REPORTRACE(drsThread) return default;} return method;

#define DRS_REPORTRACE(WriteThread) \
NSString *errorStr = [NSString stringWithFormat:@"Data Race in \n%s, pls check your code", __PRETTY_FUNCTION__]; \
DRS_ReportDataRace(errorStr, WriteThread); \

typedef BOOL(^DataRaceScanerCallBack)(NSString *msg, NSString *stack);

CG_EXTERN BOOL DRS_JudgeIfDataRace(NSNumber *thread);
CG_EXTERN void DRS_ReportDataRace(NSString *error, NSNumber *writingThread);
CG_EXTERN void DRS_ISSwizzleInstanceMethod(Class className, SEL originalSelector, SEL alternativeSelector);

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (DataRaceScaner)
@property (nonatomic, strong) NSNumber *drs_thread; //记录当前写操作的线程信息
- (void)drs_startWritingCompletion:(dispatch_block_t)block;
@end

NS_ASSUME_NONNULL_END
