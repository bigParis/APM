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

BOOL GetSystemWakeup(NSInteger *interrupt_wakeup, NSInteger *timer_wakeup)
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
    return true;
  }
  else {
    if (interrupt_wakeup) {
      *interrupt_wakeup = 0;
    }
    if (timer_wakeup) {
      *timer_wakeup = 0;
    }
    return false;
  }
}

@interface BPWakeupVC ()
@property (nonatomic, strong) NSThread *thread;
@property (nonatomic, strong) NSThread *thread2;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) UILabel *wakeupCount;
@end

@implementation BPWakeupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.f repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"wake up count:%@", @([self p_getCurrentWakeups]));
        self.wakeupCount.text = [NSString stringWithFormat:@"%@", @([self p_getCurrentWakeups])];
    }];
//    [self startTimer1:0.0001];
//    [self startTimer2:0.05];
//    [self createThread];
//    [self initViews];
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
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(loop) object:nil];
    [self.thread start];
    
    self.thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(loop2) object:nil];
    [self.thread2 start];
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
        [self performSelector:@selector(excuteTask) onThread:self.thread2 withObject:nil waitUntilDone:NO];
    }];
//    [timer fire];
    
}

- (void)excuteTask
{
    NSLog(@"任务在子线程中执行:%@",[NSThread currentThread]);
}

- (NSInteger)p_getCurrentWakeups
{
    NSInteger wakeup = 0, timer_w = 0;
    GetSystemWakeup(&wakeup, &timer_w);
    return wakeup;
}
@end
