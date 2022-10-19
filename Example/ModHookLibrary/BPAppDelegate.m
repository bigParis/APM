//
//  BPAppDelegate.m
//  ModHookLibrary
//
//  Created by wangfei5 on 09/24/2021.
//  Copyright (c) 2021 wangfei5. All rights reserved.
//

#import "BPAppDelegate.h"
#import "BPMainTabBarController.h"
#include <mach-o/dyld.h>
#import <sys/kdebug_signpost.h>
//#import <Matrix/Matrix.h>
#ifdef DEBUG
//#import <EchoSDK/ECOClient.h>
//#import <DoraemonKit/DoraemonManager.h>
#endif
#import "NSMutableArray+hook.h"

@interface BPAppDelegate ()

@end

@implementation BPAppDelegate
#define SECOND 1000000
// 指定一个cleanup方法，注意入参是所修饰变量的地址，类型要一样
// 对于指向objc对象的指针(id *)，如果不强制声明__strong默认是__autoreleasing，造成类型不匹配
static void stringCleanUp(__strong NSString **string) {
    NSLog(@"stringCleanUp:%@", *string);
}
//// 在某个方法中：
//{
//    __strong NSString *string __attribute__((cleanup(stringCleanUp))) = @"sunnyxx";
//} // 当运行到这个作用域结束时，自动调用stringCleanUp

static void add_image_callback(const struct mach_header *mhp, intptr_t slide)
{
    kdebug_signpost_start(20,0,0,0,3);
    usleep(0.01 *SECOND);
    kdebug_signpost_end(20,0,0,0,3);
}
// void(^block)(void)的指针是void(^*block)(void)
static void blockCleanUp(__strong void(^*block)(void)) {
    (*block)();
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    __strong NSString *string __attribute__((cleanup(stringCleanUp))) = @"sunnyxx";
//    // 加了个`unused`的attribute用来消除`unused variable`的warning
//     __strong void(^block)(void) __attribute__((cleanup(blockCleanUp), unused)) = ^{
//         NSLog(@"I'm dying...");
//     };
//    [NSMutableArray startHook];
#ifdef DEBUG
//    [[ECOClient sharedClient] start];
//    [[DoraemonManager shareInstance] installWithPid:@"productId"];//productId为在“平台端操作指南”中申请的产品id
#endif
    BPMainTabBarController *root = [[BPMainTabBarController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:root];
    if (!self.window) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.backgroundColor = UIColor.whiteColor;
    }
//    UIImage *image = [UIImage imageNamed:@"memory_test.jpeg"];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = nav;
    
//    Matrix *matrix = [Matrix sharedInstance];
//    MatrixBuilder *curBuilder = [[MatrixBuilder alloc] init];
//    curBuilder.pluginListener = self; // pluginListener 回调 plugin 的相关事件
//    [MatrixAdapter sharedInstance].delegate = self;
//    WCCrashBlockMonitorPlugin *crashBlockPlugin = [[WCCrashBlockMonitorPlugin alloc] init];
//    [crashBlockPlugin startTrackCPU];
//    [curBuilder addPlugin:crashBlockPlugin]; // 添加卡顿和崩溃监控
        
//    WCMemoryStatPlugin *memoryStatPlugin = [[WCMemoryStatPlugin alloc] init];
//    [curBuilder addPlugin:memoryStatPlugin]; // 添加内存监控功能

//    WCFPSMonitorPlugin *fpsMonitorPlugin = [[WCFPSMonitorPlugin alloc] init];
//    [curBuilder addPlugin:fpsMonitorPlugin]; // 添加 fps 监控功能
        
//    [matrix addMatrixBuilder:curBuilder];
        
//    [crashBlockPlugin start]; // 开启卡顿和崩溃监控
//    [memoryStatPlugin start]; // 开启内存监控
//    [fpsMonitorPlugin start]; // 开启 fps 监控
//    crashBlockPlugin.pluginConfig.blockMonitorConfiguration.bPrintCPUUsage = YES;
//    crashBlockPlugin.pluginConfig.blockMonitorConfiguration.bGetCPUHighLog = YES;
    return YES;
}

//- (void)onReportIssue:(MatrixIssue *)issue
//{
//    NSLog(@"");
//}

//- (BOOL)matrixShouldLog:(MXLogLevel)level
//{
//    return YES;
//}

//- (void)matrixLog:(MXLogLevel)logLevel module:(const char *)module file:(const char *)file line:(int)line funcName:(const char *)funcName message:(NSString *)message
//{
//    NSLog(@"%@", message);
//}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
