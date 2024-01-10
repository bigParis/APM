//
//  BPRunLoopViewController.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2023/2/9.
//  Copyright © 2023 wangfei5. All rights reserved.
//

#import "BPRunLoopViewController.h"

@interface BPRunLoopViewController ()
//@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) NSTimer *nsTimer;
@end

@implementation BPRunLoopViewController

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    [self.nsTimer invalidate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *test = @[@"1", @"2", @"3"];
    NSArray *final = [test subarrayWithRange:NSMakeRange(0, 0)];
    [self performSelector:@selector(doSomeThing) withObject:nil afterDelay:120];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self doSomeThing];
//    });
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:20.f target:self selector:@selector(doSomeThing) userInfo:nil repeats:NO];
//    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
//    dispatch_source_set_timer(timer,
//                              dispatch_walltime(NULL, 10 * NSEC_PER_SEC),
//                              DISPATCH_TIME_FOREVER,
//                              (1ull * NSEC_PER_SEC) / 10);
//    dispatch_source_set_event_handler(timer, ^{
//        NSLog(@"test");
//    });
//    dispatch_resume(timer);
//    self.timer = timer;
//    self.nsTimer = [NSTimer scheduledTimerWithTimeInterval:2.f target:self selector:@selector(doSomeThing) userInfo:nil repeats:YES];
}

- (void)doSomeThing
{
    NSLog(@"%s", __FUNCTION__);
}

@end
