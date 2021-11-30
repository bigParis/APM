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
#import "BPTaskView.h"

@interface BPTaskTestViewController ()<IUnifiedManagementDelegate>

@property (nonatomic, strong) YYUnifiedTaskManager *taskMgr;
@property (nonatomic, weak) UIButton *forceBtn;
@property (nonatomic, weak) UIButton *notForceBtn;
@property (nonatomic, weak) UIButton *bubbleBtn;
@property (nonatomic, weak) UIButton *stopBtn;
@property (nonatomic, weak) UIButton *immediatellyBtn;
@property (nonatomic, strong) YYUnifiedTaskModel *tx;
@property (nonatomic, strong) BPTaskView *topTipsView;
@property (nonatomic, strong) BPTaskView *bottomTipsView;
@property (nonatomic, weak) UIButton *topBubble;
@property (nonatomic, weak) UIButton *bottomBubble;
@end

@implementation BPTaskTestViewController

- (void)dealloc
{
    NSMutableArray *tmp = [@[] mutableCopy];
    for (int i = 0; i < 10; ++i) {
        [tmp addObject:[NSString stringWithFormat:@"popup_task%@", @(i+1)]];
    }
    [[YYUnifiedTaskManager sharedManager] removeTasks:tmp];
//    [[YYUnifiedTaskManager sharedManager] removeCurrentTaskList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    YYUnifiedTaskManager *mgr = [YYUnifiedTaskManager sharedManager];
//    YYUnifiedTaskModel *t1 = [[YYUnifiedTaskModel alloc] initWithTaskId:@"popup_task1" taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:5];
//    [mgr addTask:t1 completion:nil];
//
//    YYUnifiedTaskModel *t2 = [[YYUnifiedTaskModel alloc] initWithTaskId:@"popup_task2" taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:9];
//    [mgr addTask:t2 completion:nil];
////    self.tx = t1;
//    [YYUnifiedTaskManager sharedManager] = mgr;
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
    
    UIButton *immediatellyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [immediatellyBtn setTitle:@"立即" forState:UIControlStateNormal];
    [immediatellyBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [immediatellyBtn setBackgroundColor:UIColor.cyanColor];
    [immediatellyBtn addTarget:self action:@selector(onImmediatellyClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:immediatellyBtn];
    self.immediatellyBtn = immediatellyBtn;
    
    UIButton *topBubble = [UIButton buttonWithType:UIButtonTypeSystem];
    [topBubble setTitle:@"顶部气泡" forState:UIControlStateNormal];
    [topBubble setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [topBubble setBackgroundColor:UIColor.cyanColor];
    [topBubble addTarget:self action:@selector(onTopBubbleClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBubble];
    self.topBubble = topBubble;
    
    UIButton *bottomBubble = [UIButton buttonWithType:UIButtonTypeSystem];
    [bottomBubble setTitle:@"底部气泡" forState:UIControlStateNormal];
    [bottomBubble setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [bottomBubble setBackgroundColor:UIColor.cyanColor];
    [bottomBubble addTarget:self action:@selector(onBottomBubbleClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomBubble];
    self.bottomBubble = bottomBubble;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.notForceBtn.frame = CGRectMake(0, 0, 120, 30);
    self.notForceBtn.center = CGPointMake(self.view.center.x, 130);
    self.forceBtn.frame = CGRectMake(CGRectGetMinX(self.notForceBtn.frame), CGRectGetMaxY(self.notForceBtn.frame) + 10, 120, 30);
    self.stopBtn.frame = CGRectMake(CGRectGetMinX(self.notForceBtn.frame), CGRectGetMaxY(self.forceBtn.frame) + 10, 120, 30);
    self.bubbleBtn.frame = CGRectMake(CGRectGetMinX(self.notForceBtn.frame), CGRectGetMaxY(self.stopBtn.frame) + 10, 120, 30);
    self.immediatellyBtn.frame = CGRectMake(CGRectGetMinX(self.notForceBtn.frame), CGRectGetMaxY(self.bubbleBtn.frame) + 10, 120, 30);
    self.topBubble.frame = CGRectMake(CGRectGetMinX(self.notForceBtn.frame), CGRectGetMaxY(self.immediatellyBtn.frame) + 10, 120, 30);
    self.bottomBubble.frame = CGRectMake(CGRectGetMinX(self.notForceBtn.frame), CGRectGetMaxY(self.topBubble.frame) + 10, 120, 30);
}

- (void)onStopClicked
{
    NSLog(@"stop clicked");
    [[YYUnifiedTaskManager sharedManager] removeTasks:@[@"bubble_task1"]];
    [[YYUnifiedTaskManager sharedManager] removeTasks:@[@"bubble_task1"]];
}

- (void)onForceClicked
{
    static int x = 1;
    x += 2;
    NSString *taskId = [NSString stringWithFormat:@"popup_task%@", @(x)];
    NSLog(@"will add force:%@", taskId);
    YYUnifiedTaskModel *tx = [[YYUnifiedTaskModel alloc] initWithTaskId:taskId taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:3];
    [[YYUnifiedTaskManager sharedManager] addTask:tx completion:nil];
}

- (void)onNotForceClicked
{
    static int y = 0;
    y+=2;
    NSString *taskId = [NSString stringWithFormat:@"popup_task%@", @(y)];
    NSLog(@"will add not force:%@", taskId);
    YYUnifiedTaskModel *tx = [[YYUnifiedTaskModel alloc] initWithTaskId:taskId taskType:YYUnifiedTaskTypeNone expectedDuration:10 delay:3];
    [[YYUnifiedTaskManager sharedManager] addTask:tx completion:nil];
}

- (void)onBubbleClicked
{
    static int z = 0;
    z+=1;
    NSString *taskId = [NSString stringWithFormat:@"bubble_task%@", @(z)];
    NSLog(@"will add bubble:%@", taskId);
    if (z % 2) {
        YYUnifiedTaskModel *tx = [[YYUnifiedTaskModel alloc] initWithTaskId:taskId taskType:YYUnifiedTaskTypeBubble expectedDuration:10 delay:0 position:YYUnifiedTaskShownPositionTop delegate:self];
        [[YYUnifiedTaskManager sharedManager] addTask:tx completion:nil];
    } else {
        YYUnifiedTaskModel *tx = [[YYUnifiedTaskModel alloc] initWithTaskId:taskId taskType:YYUnifiedTaskTypeBubble expectedDuration:10 delay:0 position:YYUnifiedTaskShownPositionBottom delegate:self];
        [[YYUnifiedTaskManager sharedManager] addTask:tx completion:nil];
    }
}

- (void)onImmediatellyClicked
{
    
}

- (void)onTopBubbleClicked
{
    self.topTipsView = [[BPTaskView alloc] init];
    __weak __typeof(self) weakSelf = self;
    self.topTipsView.willShowBlock = ^{
        weakSelf.topTipsView.frame = CGRectMake((weakSelf.view.bounds.size.width - 100) * 0.5, 60, 100, 20);
    };
    [self.topTipsView showInView:self.view position:YYBubblePostionTypeBottom duration:10 taskId:@"bubble_task1" expectedDelay:0 showImmediately:NO];
}

- (void)onBottomBubbleClicked
{
    self.bottomTipsView = [[BPTaskView alloc] init];
    __weak __typeof(self) weakSelf = self;
    self.bottomTipsView.willShowBlock = ^{
        weakSelf.bottomTipsView.backgroundColor = UIColor.redColor;
        weakSelf.bottomTipsView.frame = CGRectMake((weakSelf.view.bounds.size.width - 100) * 0.5, weakSelf.view.bounds.size.height - 60, 100, 20);
    };
    [self.bottomTipsView showInView:self.view position:YYBubblePostionTypeTop duration:10 taskId:@"bubble_task2" expectedDelay:5 showImmediately:NO];
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
