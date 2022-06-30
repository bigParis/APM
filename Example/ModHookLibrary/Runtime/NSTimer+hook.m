//
//  NSTimer+hook.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/5/12.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "NSTimer+hook.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/ldsyms.h>
#include <limits.h>
#include <mach-o/dyld.h>
#include <mach-o/nlist.h>
#include <string.h>
#import <objc/message.h>
#import "BPTimerMonitor.h"

unsigned int ldCount;
const char **ldClasses;

struct __block_impl {
    void *isa;
    int Flags;
    int Reserved;
    void *FuncPtr;
};

@implementation NSTimer (hook)

+ (void)load
{
    Class metaClass = object_getClass([self class]);
    unsigned int count;
    Method *methods = class_copyMethodList(metaClass, &count);
    for (int i = 0; i < count; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        NSString *name = NSStringFromSelector(selector);
//        NSLog(@"方法 名字 ==== %@",name);
//        NSLog(@"Test '%@' completed successfuly", [name substringFromIndex:4]);
    }
//    int imageCount = (int)_dyld_image_count();
//
//    for(int iImg = 0; iImg < imageCount; iImg++) {
//
//        const char* path = _dyld_get_image_name((unsigned)iImg);
//        NSString *imagePath = [NSString stringWithUTF8String:path];
//
//        NSBundle* mainBundle = [NSBundle mainBundle];
//        NSString* bundlePath = [mainBundle bundlePath];
//
//        if ([imagePath containsString:bundlePath] && ![imagePath containsString:@".dylib"]) {
//            ldClasses = objc_copyClassNamesForImage(path, &ldCount);
//            for (int i = 0; i < ldCount; i++) {
//                NSString *className = [NSString stringWithCString:ldClasses[i] encoding:NSUTF8StringEncoding];
//                NSLog(@"className:%@", className);
//                if (![className hasPrefix:@"LDAssets"] && ![className hasPrefix:@"UI"]) {
//                    Class cls = NSClassFromString(className);
//                    if ([cls isSubclassOfClass:[UIViewController class]]) {
//                        NSLog(@"class:%@",cls);
//                        [self toHookscheduledTimerWithTimeInterval:cls];
////                        [self toHookAllMethod:cls];
//                    }
//                }
//            }
//        }
//    }
    [self toHookscheduledTimerWithTimeInterval:self.class];
    [self toHookscheduledTimerWithTimeIntervalSelector:self.class];
}

+ (void)toHookscheduledTimerWithTimeInterval:(Class)class {
    SEL selector = @selector(scheduledTimerWithTimeInterval:repeats:block:);
    SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
    
    void (^swizzledBlock)(NSTimer *) = ^(NSTimer *timer) {
        NSTimeInterval start = [self currentTime];
        ((void(*)(id, SEL))objc_msgSend)(timer, swizzledSelector);
        NSTimeInterval end = [self currentTime];
        NSTimeInterval cast = end - start;
        NSLog(@"swizzled viewDidLoad %@ %f %@",timer.class,cast,[[NSString alloc]initWithUTF8String:class_getName(class)]);
    };
    [self replaceImplementationOfKnownSelector:selector onClass:class withBlock:swizzledBlock swizzledSelector:swizzledSelector];
}

+ (void)toHookscheduledTimerWithTimeIntervalSelector:(Class)class
{
    SEL selector = @selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:);
    SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
    
    void (^swizzledBlock)(NSTimer *) = ^(NSTimer *timer) {
        NSTimeInterval start = [self currentTime];
        ((void(*)(id, SEL))objc_msgSend)(timer, swizzledSelector);
        NSTimeInterval end = [self currentTime];
        NSTimeInterval cast = end - start;
        NSLog(@"swizzled viewDidLoad %@ %f %@",timer.class,cast,[[NSString alloc]initWithUTF8String:class_getName(class)]);
    };
    [self replaceImplementationOfKnownSelector:selector onClass:class withBlock:swizzledBlock swizzledSelector:swizzledSelector];
}

+ (BOOL)replaceImplementationOfKnownSelector:(SEL)originalSelector onClass:(Class)class withBlock:(id)block swizzledSelector:(SEL)swizzledSelector {
    Class metaClass = object_getClass(class);
    Method originalMethod = class_getInstanceMethod(metaClass, originalSelector);
    if (!originalMethod) {
        return NO;
    }
#ifdef __IPHONE_6_0
    IMP implementation = imp_implementationWithBlock((id)block);
#else
    IMP implementation = imp_implementationWithBlock((__bridge void *)block);
#endif
    
    class_addMethod(metaClass, swizzledSelector, implementation, method_getTypeEncoding(originalMethod));
    Method swizzledMethod = class_getInstanceMethod(metaClass, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(metaClass,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(metaClass,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    return YES;
}

+ (NSTimeInterval)currentTime {
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

+ (SEL)swizzledSelectorForSelector:(SEL)selector {
    // 保证 selector 为唯一的，不然会死循环
    return NSSelectorFromString([NSString stringWithFormat:@"my_%@", NSStringFromSelector(selector)]);
    return @selector(my_scheduledTimerWithTimeInterval:repeats:block:);
}

+ (NSTimer *)my_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block
{
    struct __block_impl *block_imp = (__bridge struct __block_impl *)block;
    [[BPTimerMonitor sharedManager] addTimer:(__bridge NSTimer *)block_imp->isa block:block];
    return [self my_scheduledTimerWithTimeInterval:interval repeats:repeats block:block];
}

+ (NSTimer *)my_scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    [[BPTimerMonitor sharedManager] addTimer:aTarget aSelector:aSelector];
    return [self my_scheduledTimerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
}
@end
