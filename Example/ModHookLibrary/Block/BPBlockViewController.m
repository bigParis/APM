//
//  BPBlockViewController.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/12/30.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPBlockViewController.h"

@interface BPBlockViewController ()

@end

@implementation BPBlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self test1];
}

- (void)test1
{
    __weak __typeof(self) weakSelf = self;
    [self blockCompleted:^{
        [self printThx];
//        __strong __typeof(self) strongSelf = weakSelf;
//        [strongSelf printThx];
    } name:nil];
}

- (void)printThx
{
    NSLog(@"thx");
}

- (void)blockCompleted:(dispatch_block_t)completed name:(NSString *)name
{
    if (name == nil) {
        return;
    }
    
    if (completed) {
        completed();
    }
}
@end
