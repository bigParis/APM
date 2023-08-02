//
//  BPWakeupVC.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/10/18.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "BPWakeupVC.h"
#include <mach/task.h>
#include <mach/mach.h>

BOOL GetSystemWakeup(NSInteger *interrupt_wakeup, NSInteger *timer_wakeup, NSInteger *idl_wakeup)
{
  struct task_power_info info = {0};
  mach_msg_type_number_t count = TASK_POWER_INFO_COUNT;
  kern_return_t ret = task_info(current_task(), TASK_POWER_INFO, (task_info_t)&info, &count);
  if (ret == KERN_SUCCESS) {
    if (interrupt_wakeup) {
      *interrupt_wakeup = info.task_interrupt_wakeups;
    }
    if (timer_wakeup) {
      *timer_wakeup = info.task_timer_wakeups_bin_1 + info.task_timer_wakeups_bin_2;
    }
    if (idl_wakeup) {
      *idl_wakeup = info.task_platform_idle_wakeups;
    }
    return true;
  }
  else {
    if (interrupt_wakeup) {
      *interrupt_wakeup = 0;
    }
    if (timer_wakeup) {
      *timer_wakeup = 0;
    }
    if (idl_wakeup) {
      *idl_wakeup = 0;
    }
    return false;
  }
}

static const int kThreadCount = 100;
@interface BPWakeupVC ()
@property (nonatomic, strong) NSThread *thread;
@property (nonatomic, strong) NSThread *thread2;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) UILabel *wakeupCount;
@property (nonatomic, copy) dispatch_queue_t queue;
@property (nonatomic, assign) NSUInteger value;
@property (nonatomic, copy) NSString *testString;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMutableArray *threads;
@end

@implementation BPWakeupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _queue = dispatch_queue_create("test.queue", DISPATCH_QUEUE_CONCURRENT);
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10.f repeats:YES block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"==wake up count:%@", @([self p_getCurrentWakeups]));
//        self.wakeupCount.text = [NSString stringWithFormat:@"%@", @([self p_getCurrentWakeups])];
//    }];
//    [self startTimer1:0.0001];
//    [self startTimer2:0.05];
    [self createThread];
    [self initViews];
    self.lock = [[NSLock alloc] init];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self testLockWakeup];
        [self testThreadSwitch];
    });
}

- (void)testThreadSwitch
{
    for (int i = 0; i < 500000; ++i) {
        int x = i % kThreadCount;
        NSThread *thread = self.threads[x];
        [self performSelector:@selector(executePrint:) onThread:thread withObject:@{@"num": @(i)} waitUntilDone:NO];
//        [self executePrint:@{@"num": @(i)}];
    }
}

- (void)executePrint:(NSDictionary *)dict
{
    sleep(0.5f);
//    NSString *po = [NSString stringWithFormat:@"wo shiyige test string:%@", dict[@"num"]];
//    NSLog(@"self.testString:%@, thread:%@", po, [NSThread currentThread]);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.testString = [NSString stringWithFormat:@"wo shiyige test string:%@", dict[@"num"]];
//        NSLog(@"self.testString:%@", self.testString);
//    });
//    int x = [dict[@"num"] intValue];
    NSThread *thread = self.threads[kThreadCount];
    [self performSelector:@selector(executeRealPrint:) onThread:thread withObject:dict waitUntilDone:NO];
    
}
- (void)executeRealPrint:(NSDictionary *)dict
{
    NSString *po = [NSString stringWithFormat:@"wo shiyige test string:%@", dict[@"num"]];
    NSLog(@"self.testString:%@, thread:%@", po, [NSThread currentThread]);
}

- (void)testLockWakeup
{
    for (int i = 0; i < 500000; ++i) {
//        if (i %2 == 0) {
//            [self performSelector:@selector(executeWrite:) onThread:self.thread withObject:@{@"num": @(i)} waitUntilDone:NO];
//        } else {
//            [self performSelector:@selector(executeWrite:) onThread:self.thread2 withObject:@{@"num": @(i)} waitUntilDone:NO];
//        }
        int x = i % kThreadCount;
        NSThread *thread = self.threads[x];
        [self performSelector:@selector(executeWrite:) onThread:thread withObject:@{@"num": @(i)} waitUntilDone:NO];
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [self executeWrite:@{@"num": @(i)}];
//        });
//        if (i == 99999) {
//            sleep(0.5);
//            i = 0;
//        }
    }
}

- (void)executeWrite:(NSDictionary *)dict
{
    sleep(8.f);
    [self.lock lock];
    self.testString = [NSString stringWithFormat:@"wo shiyige test string:%@", dict[@"num"]];
    NSLog(@"self.testString:%@", self.testString);
    [self.lock unlock];
}

- (void)initViews
{
    UILabel *wakeupCount = [[UILabel alloc] init];
    self.wakeupCount = wakeupCount;
    [self.view addSubview:wakeupCount];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.wakeupCount.frame = CGRectMake(100, 100, 100, 30);
}

- (void)createThread
{
    for (int i = 0; i <= kThreadCount; ++i) {
        NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(loop) object:nil];
        [thread start];
        [self.threads addObject:thread];
    }
}

- (void)loop
{
    NSLog(@"start loop:%@", [NSThread currentThread]);
    NSRunLoop *theRL = [NSRunLoop currentRunLoop];
    [theRL addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [theRL run];
}

- (void)loop2
{
    NSLog(@"start loop2");
    NSRunLoop *theRL = [NSRunLoop currentRunLoop];
    [theRL addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [theRL run];
}

- (void)startTimer1:(NSTimeInterval)sec
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:sec repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSString *test = @"123";
        NSLog(@"test:%@, thread:%@", test, [NSThread currentThread]);
        [self performSelector:@selector(excuteTask) onThread:self.thread withObject:nil waitUntilDone:NO];
    }];
//    [timer fire];
    
}

- (void)startTimer2:(NSTimeInterval)sec
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:sec repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSString *test = @"123";
        NSLog(@"test:%@, thread:%@", test, [NSThread currentThread]);
//        [self performSelector:@selector(excuteTask) onThread:self.thread2 withObject:nil waitUntilDone:NO];
        dispatch_async(_queue, ^{
            [self excuteTask];
        });
    }];
//    [timer fire];
    
}

- (void)excuteTask
{
//    NSLog(@"wake up count:%@", @([self p_getCurrentWakeups]));
    
    if (self.value % 2 == 0) {
        [self logIt];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"任务在主线程中执行:%@",[NSThread currentThread]);
            [self excuteTask];
        });
    }
    self.value++;
}

- (void)logIt
{
    NSLog(@"任务在子线程中执行:%@",[NSThread currentThread]);
}

- (NSInteger)p_getCurrentWakeups
{
    NSInteger wakeup = 0, timer_w = 0, idl_wakeup = 0;
    GetSystemWakeup(&wakeup, &timer_w, &idl_wakeup);
    return wakeup;
}

- (NSMutableArray *)threads
{
    if (_threads == nil) {
        _threads = [NSMutableArray array];
    }
    return _threads;
}
@end
