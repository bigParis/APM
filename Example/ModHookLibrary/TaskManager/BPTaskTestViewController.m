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

@interface BPTaskTestViewController ()<IUnifiedManagementDelegate>
@property (nonatomic, strong) YYUnifiedTaskManager *taskMgr;
@property (nonatomic, weak) UIButton *forceBtn;
@property (nonatomic, weak) UIButton *notForceBtn;
@property (nonatomic, weak) UIButton *bubbleBtn;
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
//    YYUnifiedTaskModel *t1 = [[YYUnifiedTaskModel alloc] initWithTaskId:@"popup_task1" taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:5];
//    [mgr addTask:t1];
//
//    YYUnifiedTaskModel *t2 = [[YYUnifiedTaskModel alloc] initWithTaskId:@"popup_task2" taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:9];
//    [mgr addTask:t2];
    
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
    
    UIButton *bubbleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [bubbleBtn setTitle:@"气泡" forState:UIControlStateNormal];
    [bubbleBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [bubbleBtn setBackgroundColor:UIColor.greenColor];
    [bubbleBtn addTarget:self action:@selector(onBubbleClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bubbleBtn];
    self.bubbleBtn = bubbleBtn;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.notForceBtn.frame = CGRectMake(0, 0, 120, 30);
    self.notForceBtn.center = self.view.center;
    self.forceBtn.frame = CGRectMake(CGRectGetMinX(self.notForceBtn.frame), CGRectGetMaxY(self.notForceBtn.frame) + 10, 120, 30);
    self.stopBtn.frame = CGRectMake(CGRectGetMinX(self.notForceBtn.frame), CGRectGetMaxY(self.forceBtn.frame) + 10, 120, 30);
    self.bubbleBtn.frame = CGRectMake(CGRectGetMinX(self.notForceBtn.frame), CGRectGetMaxY(self.stopBtn.frame) + 10, 120, 30);
}

- (void)onStopClicked
{
    NSLog(@"stop clicked");
}

- (void)onForceClicked
{
    static int x = 1;
    x += 2;
    NSString *taskId = [NSString stringWithFormat:@"popup_task%@", @(x)];
    NSLog(@"will add force:%@", taskId);
    YYUnifiedTaskModel *tx = [[YYUnifiedTaskModel alloc] initWithTaskId:taskId taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:3];
    [self.taskMgr addTask:tx completion:nil];
}

- (void)onNotForceClicked
{
    static int y = 0;
    y+=2;
    NSString *taskId = [NSString stringWithFormat:@"popup_task%@", @(y)];
    NSLog(@"will add not force:%@", taskId);
    YYUnifiedTaskModel *tx = [[YYUnifiedTaskModel alloc] initWithTaskId:taskId taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:3];
    [self.taskMgr addTask:tx completion:nil];
}

- (void)onBubbleClicked
{
    static int z = 0;
    z+=1;
    NSString *taskId = [NSString stringWithFormat:@"bubble_task%@", @(z)];
    NSLog(@"will add bubble:%@", taskId);
    if (z % 2) {
        YYUnifiedTaskModel *tx = [[YYUnifiedTaskModel alloc] initWithTaskId:taskId taskType:YYUnifiedTaskTypeBubble expectedDuration:10 delay:3 position:YYUnifiedTaskShownPositionTop delegate:self];
        [self.taskMgr addTask:tx completion:nil];
    } else {
        YYUnifiedTaskModel *tx = [[YYUnifiedTaskModel alloc] initWithTaskId:taskId taskType:YYUnifiedTaskTypeBubble expectedDuration:10 delay:3 position:YYUnifiedTaskShownPositionBottom delegate:self];
        [self.taskMgr addTask:tx completion:nil];
    }
    
}

- (void)taskShouldShow:(NSString *)taskId completion:(void (^)(BOOL))completion
{
    NSLog(@"%s:taskId:%@", __func__, taskId);
}

- (void)taskShouldDismiss:(NSString *)taskId completion:(void (^)(BOOL))completion
{
    NSLog(@"%s:taskId:%@", __func__, taskId);
}

- (void)taskHasDiscarded:(NSString *)taskId completion:(void (^)(BOOL))completion
{
    NSLog(@"%s:taskId:%@", __func__, taskId);
}
@end
