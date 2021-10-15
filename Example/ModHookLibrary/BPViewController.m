//
//  BPViewController.m
//  ModHookLibrary
//
//  Created by wangfei5 on 09/24/2021.
//  Copyright (c) 2021 wangfei5. All rights reserved.
//

#import "BPViewController.h"
#import <BPModInitFuncHook.h>
#import <BPTestCode1.h>

#import "YYUnifiedTaskManager.h"
#import "YYUnifiedTaskModel.h"

@interface BPViewController ()
@property (nonatomic, strong) YYUnifiedTaskManager *task;
@end

@implementation BPViewController

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//	// Do any additional setup after loading the view, typically from a nib.
//    double total = [BPModInitFuncHook total];
//    BPTestCode1 *obj1 = [[BPTestCode1 alloc] init];
//    [obj1 testCode1];
//    NSLog(@"-%f", total);
//}
- (void)viewDidLoad {
    [super viewDidLoad];
//    BPTestCode1 *obj1 = [[BPTestCode1 alloc] init];
//    [obj1 testCode1];
//    [BPModInitFuncHook setOpen:YES];
    
    YYUnifiedTaskManager *p = [[YYUnifiedTaskManager alloc] init];
    YYUnifiedTaskModel *m = [[YYUnifiedTaskModel alloc] initWithTaskId:@"popup_task1" taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:5];
    [p addTask:m];

    YYUnifiedTaskModel *m2 = [[YYUnifiedTaskModel alloc] initWithTaskId:@"popup_task2" taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:5];
    [p addTask:m2];
    
    self.task = p;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    double tm = [BPModInitFuncHook total];
    NSLog(@"--%f", tm);
    static int x = 2;
    x++;
    YYUnifiedTaskModel *m2 = [[YYUnifiedTaskModel alloc] initWithTaskId:[NSString stringWithFormat:@"popup_task%@", @(x)] taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:5];
    [self.task addTask:m2];
    [self testCode];
    
//    self.task
}

- (BOOL)testCode {
    NSLog(@"testCode 123");
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
