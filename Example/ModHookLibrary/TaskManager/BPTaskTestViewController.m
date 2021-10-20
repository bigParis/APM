//
//  BPTaskTestViewController.m
//  ModHookLibrary_Example
//
//  Created by 王飞 on 2021/10/20.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPTaskTestViewController.h"
#import "YYUnifiedTaskManager.h"
#import "YYUnifiedTaskModel.h"

@interface BPTaskTestViewController ()
@property (nonatomic, strong) YYUnifiedTaskManager *taskMgr;

@end

@implementation BPTaskTestViewController

- (void)dealloc
{
    NSMutableArray *tmp = [@[] mutableCopy];
    for (int i = 0; i < 10; ++i) {
        [tmp addObject:[NSString stringWithFormat:@"popup_task%@", @(i+1)]];
    }
    [self.taskMgr removeTasks:tmp];
    [self.taskMgr removeCurrentTaskList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    YYUnifiedTaskManager *mgr = [YYUnifiedTaskManager sharedManager];
    YYUnifiedTaskModel *t1 = [[YYUnifiedTaskModel alloc] initWithTaskId:@"popup_task1" taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:5];
    [mgr addTask:t1];

    YYUnifiedTaskModel *t2 = [[YYUnifiedTaskModel alloc] initWithTaskId:@"popup_task2" taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:9];
    [mgr addTask:t2];
    
    self.taskMgr = mgr;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    static int x = 2;
    x++;
    YYUnifiedTaskModel *tx = [[YYUnifiedTaskModel alloc] initWithTaskId:[NSString stringWithFormat:@"popup_task%@", @(x)] taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:5];
    [self.taskMgr addTask:tx];
}

@end
