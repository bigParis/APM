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
@property (nonatomic, weak) UIButton *forceBtn;
@property (nonatomic, weak) UIButton *notForceBtn;
@property (nonatomic, weak) UIButton *stopBtn;
@end

@implementation BPTaskTestViewController

- (void)dealloc
{
    NSMutableArray *tmp = [@[] mutableCopy];
    for (int i = 0; i < 10; ++i) {
        [tmp addObject:[NSString stringWithFormat:@"popup_task%@", @(i+1)]];
    }
    [self.taskMgr removeTasks:tmp];
//    [self.taskMgr removeCurrentTaskList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    YYUnifiedTaskManager *mgr = [YYUnifiedTaskManager sharedManager];
    YYUnifiedTaskModel *t1 = [[YYUnifiedTaskModel alloc] initWithTaskId:@"popup_task1" taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:5];
    [mgr addTask:t1];

    YYUnifiedTaskModel *t2 = [[YYUnifiedTaskModel alloc] initWithTaskId:@"popup_task2" taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:9];
    [mgr addTask:t2];
    
    self.taskMgr = mgr;
    [self initViews];
}

- (void)initViews
{
    UIButton *forceBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [forceBtn setTitle:@"强制" forState:UIControlStateNormal];
    [forceBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [forceBtn setBackgroundColor:UIColor.redColor];
    [forceBtn addTarget:self action:@selector(onForceClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forceBtn];
    self.forceBtn = forceBtn;
    
    UIButton *notForceBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [notForceBtn setTitle:@"非强制" forState:UIControlStateNormal];
    [notForceBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [notForceBtn setBackgroundColor:UIColor.blueColor];
    [notForceBtn addTarget:self action:@selector(onNotForceClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:notForceBtn];
    self.notForceBtn = notForceBtn;
    
    UIButton *stopBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [stopBtn setTitle:@"停止" forState:UIControlStateNormal];
    [stopBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [stopBtn setBackgroundColor:UIColor.blueColor];
    [stopBtn addTarget:self action:@selector(onStopClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopBtn];
    self.stopBtn = stopBtn;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.notForceBtn.frame = CGRectMake(0, 0, 120, 30);
    self.notForceBtn.center = self.view.center;
    self.forceBtn.frame = CGRectMake(CGRectGetMinX(self.notForceBtn.frame), CGRectGetMaxY(self.notForceBtn.frame) + 10, 120, 30);
    self.stopBtn.frame = CGRectMake(CGRectGetMinX(self.notForceBtn.frame), CGRectGetMaxY(self.forceBtn.frame) + 10, 120, 30);
}

- (void)onStopClicked
{
    NSLog(@"stop clicked");
}

- (void)onForceClicked
{
    NSLog(@"add force");
    static int x = 0;
    x+=2;
    YYUnifiedTaskModel *tx = [[YYUnifiedTaskModel alloc] initWithTaskId:[NSString stringWithFormat:@"popup_task%@", @(x)] taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:5];
    [self.taskMgr addTask:tx];
}

- (void)onNotForceClicked
{
    NSLog(@"add not force");
    static int y = 1;
    y += 2;
    YYUnifiedTaskModel *tx = [[YYUnifiedTaskModel alloc] initWithTaskId:[NSString stringWithFormat:@"popup_task%@", @(y)] taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:5];
    [self.taskMgr addTask:tx];
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    static int x = 2;
//    x++;
//    YYUnifiedTaskModel *tx = [[YYUnifiedTaskModel alloc] initWithTaskId:[NSString stringWithFormat:@"popup_task%@", @(x)] taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:5];
//    [self.taskMgr addTask:tx];
//}

@end
