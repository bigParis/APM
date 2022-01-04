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
#import <Masonry/Masonry.h>

@interface BPTaskTestViewController ()<IUnifiedManagementDelegate>

@property (nonatomic, strong) YYUnifiedTaskManager *taskMgr;
@property (nonatomic, weak) UIButton *forceBtn;
@property (nonatomic, weak) UIButton *notForceBtn;

@property (nonatomic, weak) UIView *taskBtnView;
@property (nonatomic, weak) UIButton *bubbleBtn;
@property (nonatomic, weak) UIButton *stopBtn;
@property (nonatomic, weak) UIButton *immediatellyBtn;
@property (nonatomic, weak) UIButton *topBubble;
@property (nonatomic, weak) UIButton *bottomBubble;
@property (nonatomic, weak) UIButton *cycleAddTaskBtn;
@property (nonatomic, weak) UIButton *updateLayoutTaskBtn;
@property (nonatomic, weak) UIButton *restoreLayoutTaskBtn;
@property (nonatomic, weak) UIButton *adjustLayoutBtn;
@property (nonatomic, weak) UIButton *reuseBtn;
@property (nonatomic, weak) UIButton *crashBtn;
@property (nonatomic, weak) UIButton *priortyBtn;

@property (nonatomic, strong) YYUnifiedTaskModel *tx;
@property (nonatomic, strong) BPTaskView *topTipsView;
@property (nonatomic, strong) BPTaskView *bottomTipsView;
@property (nonatomic, strong) BPTaskView *longDelayTipsView;
@property (nonatomic, strong) BPTaskView *immediatelyTipsView;
@property (nonatomic, strong) BPTaskView *masonryTipsView;

@property (nonatomic, strong) NSMutableArray *taskArray;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isTop;
@property (nonatomic, assign) CGFloat reuseOffset;
@end

@implementation BPTaskTestViewController

- (void)dealloc
{
//    NSMutableArray *tmp = [@[] mutableCopy];
//    for (int i = 0; i < 10; ++i) {
//        [tmp addObject:[NSString stringWithFormat:@"bubble_task%@", @(i+1)]];
//    }
//    [[YYUnifiedTaskManager sharedManager] removeTasks:tmp];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
//    [self prepareReuseBubble];
    [self prepareTwoBubble];
//    [self prepareCycleTask];
//    [self prepareMasonryBubble];
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
    
    UIView *taskBtnView = [[UIView alloc] init];
    taskBtnView.backgroundColor = UIColor.grayColor;
    [self.view addSubview:taskBtnView];
    self.taskBtnView = taskBtnView;
    
    UIButton *bubbleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [bubbleBtn setTitle:@"延时气泡" forState:UIControlStateNormal];
    [bubbleBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [bubbleBtn setBackgroundColor:UIColor.greenColor];
    [bubbleBtn addTarget:self action:@selector(onLongDelayBubbleClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.taskBtnView addSubview:bubbleBtn];
    self.bubbleBtn = bubbleBtn;
    
    UIButton *immediatellyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [immediatellyBtn setTitle:@"立即显示" forState:UIControlStateNormal];
    [immediatellyBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [immediatellyBtn setBackgroundColor:UIColor.cyanColor];
    [immediatellyBtn addTarget:self action:@selector(onImmediatellyClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.taskBtnView addSubview:immediatellyBtn];
    self.immediatellyBtn = immediatellyBtn;
    
    UIButton *topBubble = [UIButton buttonWithType:UIButtonTypeSystem];
    [topBubble setTitle:@"顶部气泡" forState:UIControlStateNormal];
    [topBubble setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [topBubble setBackgroundColor:UIColor.cyanColor];
    [topBubble addTarget:self action:@selector(onTopBubbleClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.taskBtnView addSubview:topBubble];
    self.topBubble = topBubble;
    
    UIButton *bottomBubble = [UIButton buttonWithType:UIButtonTypeSystem];
    [bottomBubble setTitle:@"底部气泡" forState:UIControlStateNormal];
    [bottomBubble setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [bottomBubble setBackgroundColor:UIColor.cyanColor];
    [bottomBubble addTarget:self action:@selector(onBottomBubbleClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.taskBtnView addSubview:bottomBubble];
    self.bottomBubble = bottomBubble;
    
    UIButton *cycleAddTaskBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cycleAddTaskBtn setTitle:@"循环执行任务" forState:UIControlStateNormal];
    [cycleAddTaskBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [cycleAddTaskBtn setBackgroundColor:UIColor.cyanColor];
    [cycleAddTaskBtn addTarget:self action:@selector(onCycleAddClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.taskBtnView addSubview:cycleAddTaskBtn];
    self.cycleAddTaskBtn = cycleAddTaskBtn;
    
    UIButton *updateLayoutTaskBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [updateLayoutTaskBtn setTitle:@"更新布局气泡" forState:UIControlStateNormal];
    [updateLayoutTaskBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [updateLayoutTaskBtn setBackgroundColor:UIColor.cyanColor];
    [updateLayoutTaskBtn addTarget:self action:@selector(onUpdateLayoutClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.taskBtnView addSubview:updateLayoutTaskBtn];
    self.updateLayoutTaskBtn = updateLayoutTaskBtn;
    
    UIButton *restoreLayoutTaskBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [restoreLayoutTaskBtn setTitle:@"恢复布局气泡" forState:UIControlStateNormal];
    [restoreLayoutTaskBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [restoreLayoutTaskBtn setBackgroundColor:UIColor.cyanColor];
    [restoreLayoutTaskBtn addTarget:self action:@selector(onRestoreLayoutClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.taskBtnView addSubview:restoreLayoutTaskBtn];
    self.restoreLayoutTaskBtn = restoreLayoutTaskBtn;
    
    UIButton *reuseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [reuseBtn setTitle:@"复用气泡" forState:UIControlStateNormal];
    [reuseBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [reuseBtn setBackgroundColor:UIColor.cyanColor];
    [reuseBtn addTarget:self action:@selector(onReuseClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.taskBtnView addSubview:reuseBtn];
    self.reuseBtn = reuseBtn;
    
    
    UIButton *adjustLayoutBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [adjustLayoutBtn setTitle:@"上下布局切换" forState:UIControlStateNormal];
    [adjustLayoutBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [adjustLayoutBtn setBackgroundColor:UIColor.cyanColor];
    [adjustLayoutBtn addTarget:self action:@selector(onAjustLayoutClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.taskBtnView addSubview:adjustLayoutBtn];
    self.adjustLayoutBtn = adjustLayoutBtn;
    
    UIButton *crashBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [crashBtn setTitle:@"崩溃任务" forState:UIControlStateNormal];
    [crashBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [crashBtn setBackgroundColor:UIColor.cyanColor];
    [crashBtn addTarget:self action:@selector(onCrashClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.taskBtnView addSubview:crashBtn];
    self.crashBtn = crashBtn;
    
    UIButton *priortyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [priortyBtn setTitle:@"优先级" forState:UIControlStateNormal];
    [priortyBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [priortyBtn setBackgroundColor:UIColor.cyanColor];
    [priortyBtn addTarget:self action:@selector(onPriortyBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.taskBtnView addSubview:priortyBtn];
    self.priortyBtn = priortyBtn;
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.notForceBtn.frame = CGRectMake(0, 0, 120, 30);
    self.notForceBtn.center = CGPointMake(self.view.center.x, 130);
    self.forceBtn.frame = CGRectMake(CGRectGetMinX(self.notForceBtn.frame), CGRectGetMaxY(self.notForceBtn.frame) + 10, 120, 30);
    self.stopBtn.frame = CGRectMake(CGRectGetMinX(self.notForceBtn.frame), CGRectGetMaxY(self.forceBtn.frame) + 10, 120, 30);
    self.taskBtnView.frame = CGRectMake(10, CGRectGetMaxY(self.stopBtn.frame) + 10, self.view.bounds.size.width - 20, self.view.bounds.size.height * 0.5);
    
    self.bubbleBtn.frame = CGRectMake(30, 10, 120, 30);
    self.immediatellyBtn.frame = CGRectMake(30, CGRectGetMaxY(self.bubbleBtn.frame) + 10, 120, 30);
    self.topBubble.frame = CGRectMake(30, CGRectGetMaxY(self.immediatellyBtn.frame) + 10, 120, 30);
    self.bottomBubble.frame = CGRectMake(30, CGRectGetMaxY(self.topBubble.frame) + 10, 120, 30);
    self.cycleAddTaskBtn.frame = CGRectMake(30, CGRectGetMaxY(self.bottomBubble.frame) + 10, 120, 30);
    self.updateLayoutTaskBtn.frame = CGRectMake(30, CGRectGetMaxY(self.cycleAddTaskBtn.frame) + 10, 120, 30);
    self.restoreLayoutTaskBtn.frame = CGRectMake(30, CGRectGetMaxY(self.updateLayoutTaskBtn.frame) + 10, 120, 30);
    self.reuseBtn.frame = CGRectMake(30, CGRectGetMaxY(self.restoreLayoutTaskBtn.frame) + 10, 120, 30);
    self.crashBtn.frame = CGRectMake(30, CGRectGetMaxY(self.reuseBtn.frame) + 10, 120, 30);
    self.priortyBtn.frame = CGRectMake(30, CGRectGetMaxY(self.crashBtn.frame) + 10, 120, 30);

    self.adjustLayoutBtn.frame = CGRectMake(CGRectGetMaxX(self.bubbleBtn.frame) + 20, 10, 120, 30);
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

- (void)prepareReuseBubble
{
    self.bottomTipsView = [[BPTaskView alloc] init];
    __weak __typeof(self) weakSelf = self;
    self.bottomTipsView.willShowBlock = ^{
        __strong __typeof(self) strongSelf = weakSelf;
        strongSelf.bottomTipsView.frame = CGRectMake((strongSelf.view.bounds.size.width - 100) * 0.5, CGRectGetMinY(strongSelf.taskBtnView.frame) + strongSelf.reuseOffset, 100, 20);
    };
}

- (void)prepareTwoBubble
{
    self.bottomTipsView = [[BPTaskView alloc] init];
    __weak __typeof(self) weakSelf = self;
    self.bottomTipsView.willShowBlock = ^{
        __strong __typeof(self) strongSelf = weakSelf;
//        strongSelf.bottomTipsView.frame = CGRectMake((strongSelf.view.bounds.size.width - 100) * 0.5, CGRectGetMinY(strongSelf.taskBtnView.frame), 100, 20);
////        CGRectMake(10, CGRectGetMaxY(self.stopBtn.frame) + 10, self.view.bounds.size.width - 20, self.view.bounds.size.height * 0.5);
//        [strongSelf.view setNeedsLayout];
//        [strongSelf.view layoutIfNeeded];
//        strongSelf.taskBtnView.frame = CGRectMake(10, CGRectGetMaxY(strongSelf.bottomTipsView.frame) + 10, self.view.bounds.size.width - 20, self.view.bounds.size.height * 0.5);
//        strongSelf.bottomTipsView.backgroundColor = [UIColor blueColor];
        strongSelf.bottomTipsView.frame = CGRectMake((strongSelf.view.bounds.size.width - 100) * 0.5, strongSelf.view.bounds.size.height - 60, 100, 20);
        if (strongSelf.isTop) {
            strongSelf.bottomTipsView.backgroundColor = [UIColor redColor];
        } else {
            strongSelf.bottomTipsView.backgroundColor = [UIColor blueColor];
        }
    };
    
    self.bottomTipsView.removeFromSuperBlock = ^{
        
    };
    
    self.topTipsView = [[BPTaskView alloc] init];
    self.topTipsView.willShowBlock = ^{
        __strong __typeof(self) strongSelf = weakSelf;
        if (strongSelf.isTop) {
            strongSelf.topTipsView.frame = CGRectMake((weakSelf.view.bounds.size.width - 100) * 0.5, 60, 100, 20);
            strongSelf.topTipsView.backgroundColor = [UIColor redColor];
        } else {
            strongSelf.topTipsView.frame = CGRectMake((weakSelf.view.bounds.size.width - 100) * 0.5, weakSelf.view.bounds.size.height - 60, 100, 20);
            strongSelf.topTipsView.backgroundColor = [UIColor blueColor];
        }
    };
    
    
}

- (void)prepareCycleTask
{
    for (int i = 5 ; i < 10; i++) {
        NSString *taskId = [NSString stringWithFormat:@"bubble_task%@", @(i)];
        [self.taskArray addObject:taskId];
    }
    
//    __weak __typeof(self) weakSelf = self;
//    self.bottomTipsView.willShowBlock = ^{
//        __strong __typeof(self) strongSelf = weakSelf;
//        strongSelf.bottomTipsView.frame = CGRectMake((strongSelf.view.bounds.size.width - 100) * 0.5, 60, 100, 20);
//    };
//
//    self.bottomTipsView.discardBubbleBlock = ^{
//        __strong __typeof(self) strongSelf = weakSelf;
//        if (strongSelf.taskArray.count == 0) {
//            [strongSelf.timer invalidate];
//            strongSelf.timer = nil;
//            strongSelf.bottomTipsView = nil;
//        }
//        NSLog(@"remove task:%@", strongSelf.taskArray[0]);
//        [strongSelf.taskArray removeObjectAtIndex:0];
//    };
    
//    self.bottomTipsView.removeFromSuperBlock = ^{
//        __strong __typeof(self) strongSelf = weakSelf;
//        strongSelf.bottomTipsView = nil;
//    };
}

- (void)prepareMasonryBubble
{
    self.bottomTipsView = [[BPTaskView alloc] init];
    /// Do not crash case
//    self.masonryTipsView.frame = CGRectMake((self.view.bounds.size.width - 100) * 0.5, 60, 100, 20);
    /// Crash case
//    [self.masonryTipsView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(self.view);
//        make.width.mas_equalTo(100);
//        make.height.mas_equalTo(20);
//        make.top.mas_equalTo(60);
//    }];
    /// right case of using masonry
    __weak __typeof(self) weakSelf = self;
    self.bottomTipsView.willShowBlock = ^{
        __strong __typeof(self) strongSelf = weakSelf;
        [strongSelf.bottomTipsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(strongSelf.view);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(20);
            make.top.mas_equalTo(strongSelf.taskBtnView.mas_top).offset(strongSelf.reuseOffset);
        }];
    };
}

- (void)onLongDelayBubbleClicked
{
    static int x = 0;
    x++;
    NSString *taskId = [NSString stringWithFormat:@"bubble_task%@", @(x)];
    if (x % 2 == 1) {
        [self.longDelayTipsView showInView:self.view position:YYBubblePostionTypeTop duration:10 taskId:taskId expectedDelay:100 showImmediately:NO];
    } else {
        [self.topTipsView showInView:self.view position:YYBubblePostionTypeTop duration:10 taskId:taskId expectedDelay:100 showImmediately:NO];
    }
}

- (void)onCycleAddClicked
{
    __weak __typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (weakSelf.taskArray.count != 0) {
            [weakSelf.bottomTipsView showInView:weakSelf.view position:YYBubblePostionTypeBottom duration:3 taskId:weakSelf.taskArray.firstObject expectedDelay:0 showImmediately:NO];
        }
    }];
}

- (void)onUpdateLayoutClicked
{
    [self.topTipsView showInView:self.view position:YYBubblePostionTypeTop duration:10 taskId:@"bubble_task15" expectedDelay:15 showImmediately:NO];
}

- (void)onRestoreLayoutClicked
{
    [self.bottomTipsView showInView:self.view position:YYBubblePostionTypeBottom duration:10 taskId:@"bubble_task15" expectedDelay:1 showImmediately:NO];
}

- (void)onAjustLayoutClicked
{
    self.isTop = !self.isTop;
}

- (void)onReuseClicked
{
    __weak __typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.f repeats:YES block:^(NSTimer * _Nonnull timer) {
        static int x = 0;
        self.reuseOffset = x * 10;
        NSString *taskId = [NSString stringWithFormat:@"bubble_task%@", @(x)];
        [weakSelf.bottomTipsView showInView:weakSelf.view position:YYBubblePostionTypeTop duration:2.f taskId:taskId expectedDelay:0 showImmediately:NO];
        x++;
        if (x == 15) {
            [weakSelf.timer invalidate];
            weakSelf.timer = nil;
        }
    }];
}

- (void)onCrashClicked
{
    [self.masonryTipsView showInView:self.view position:YYBubblePostionTypeTop duration:10 taskId:@"bubble_task6" expectedDelay:5 showImmediately:NO];
}

- (void)onPriortyBtnClicked
{
    static int x = 0;
    x++;
    NSString *taskId = [NSString stringWithFormat:@"bubble_task%@", @(x)];
    self.isTop = x % 2 == 0;
    
    [self.bottomTipsView showInView:self.view position:YYBubblePostionTypeBottom duration:100 taskId:taskId expectedDelay:0 showImmediately:NO];
}

- (void)onImmediatellyClicked
{
    self.immediatelyTipsView = [[BPTaskView alloc] init];
    __weak __typeof(self) weakSelf = self;
    self.immediatelyTipsView.willShowBlock = ^{
        __strong __typeof(self) strongSelf = weakSelf;
        strongSelf.immediatelyTipsView.frame = CGRectMake((weakSelf.view.bounds.size.width - 100) * 0.5, 60, 100, 20);
    };
    [self.immediatelyTipsView showInView:self.view position:YYBubblePostionTypeTop duration:10 taskId:@"bubble_task20" expectedDelay:0 showImmediately:YES];
}

- (void)onTopBubbleClicked
{
    self.topTipsView = [[BPTaskView alloc] init];
    __weak __typeof(self) weakSelf = self;
    self.topTipsView.willShowBlock = ^{
        weakSelf.topTipsView.frame = CGRectMake((weakSelf.view.bounds.size.width - 100) * 0.5, 60, 100, 20);
    };
    [self.topTipsView showInView:self.view position:YYBubblePostionTypeTop duration:10 taskId:@"bubble_task1" expectedDelay:0 showImmediately:NO];
}

- (void)onBottomBubbleClicked
{
    self.bottomTipsView = [[BPTaskView alloc] init];
    __weak __typeof(self) weakSelf = self;
    self.bottomTipsView.willShowBlock = ^{
        weakSelf.bottomTipsView.backgroundColor = UIColor.redColor;
        weakSelf.bottomTipsView.frame = CGRectMake((weakSelf.view.bounds.size.width - 100) * 0.5, weakSelf.view.bounds.size.height - 60, 100, 20);
    };
    [self.bottomTipsView showInView:self.view position:YYBubblePostionTypeBottom duration:10 taskId:@"bubble_task2" expectedDelay:5 showImmediately:NO];
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

- (NSMutableArray *)taskArray
{
    if (_taskArray == nil) {
        _taskArray = [NSMutableArray array];
    }
    return _taskArray;
}
@end
