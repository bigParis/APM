//
//  BPHitchViewController.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2023/8/31.
//  Copyright © 2023 wangfei5. All rights reserved.
//

#import "BPHitchViewController.h"

#define kHitchPrecision 0.0001
#define kFPS60Rate 1/60.f
@interface BPHitchViewController ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, assign) CFTimeInterval preTargetFrameTime;
@property (nonatomic, assign) CFTimeInterval totalHitchTime; // 一次start到stop之间的总HitchTime
@property (nonatomic, assign) CFTimeInterval lastRecordTime;
@property (nonatomic, assign) CFTimeInterval lastLoopTime;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, strong) NSTimer *labelTimer;
@property (nonatomic, weak) UILabel *testLabel;

@end

@implementation BPHitchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *testLabel = [[UILabel alloc] init];
    testLabel.font = [UIFont systemFontOfSize:14.f];
    testLabel.textColor = [UIColor redColor];
    self.testLabel = testLabel;
    [self.view addSubview:testLabel];
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
//    _displayLink.preferredFramesPerSecond = 2;
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.startTime = CACurrentMediaTime();
    _labelTimer = [NSTimer scheduledTimerWithTimeInterval:1.1f target:self selector:@selector(refreshLabel) userInfo:nil repeats:YES];
}

- (void)refreshLabel
{
    static int x = 0;
    self.testLabel.text = [NSString stringWithFormat:@"我要显示的文案:%@", @(x++)];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.imageView.frame = CGRectMake((self.view.bounds.size.width - 300) * 0.5, (self.view.bounds.size.height - 400) * 0.5, 300, 400);
    self.testLabel.frame = CGRectMake((self.view.bounds.size.width - 300) * 0.5, (self.view.bounds.size.height - 400) * 0.5 - 30, 300, 30);
}

- (void)displayLinkCallback:(CADisplayLink *)displayLink
{
    [self onDisplayLink:displayLink];
}

- (void)onDisplayLink:(CADisplayLink *)displayLink
{
    if (self.startTime < 1e-6) {
        return;
    }
    
    if (self.preTargetFrameTime < 1e-6) {
        self.lastRecordTime = self.startTime;
        self.preTargetFrameTime = displayLink.targetTimestamp; //假设开始时间是上一帧时间
        self.lastLoopTime = displayLink.timestamp;
        CFTimeInterval current = CACurrentMediaTime();
        CFTimeInterval firstFrame = floor((current - self.startTime)/displayLink.duration);
        NSLog(@"current:%@, startTime:%@, duration:%@", @(current), @(self.startTime), @(displayLink.duration));
        if (firstFrame > 1) {
            self.totalHitchTime += (firstFrame - 1) * displayLink.duration;
        }
        return;
    }
    
    CFTimeInterval current = displayLink.timestamp;
    CFTimeInterval extCost = current - self.preTargetFrameTime;
    CFTimeInterval dt = displayLink.targetTimestamp - self.preTargetFrameTime;
    CFTimeInterval currentTime = CACurrentMediaTime();
    CFTimeInterval gap = currentTime - self.lastLoopTime;
    if ((currentTime - current) >= 0.0002) {
        NSLog(@"currentTime-timestamp:%@", @(currentTime - current));
    }
    
    if (extCost >= kHitchPrecision) { //小于0.0001忽略
        if (fabs(gap - kFPS60Rate) < 0.00001) {
            NSLog(@"lastLoopTime:%f currentTime:%f gap:%f 并不是真的卡顿", self.lastLoopTime, currentTime, (gap - kFPS60Rate));
        } else {
            CFTimeInterval realGap = MIN(extCost, gap - kFPS60Rate);
            self.totalHitchTime += realGap;
            NSLog(@"卡顿了extCost:%@, preTargetFrameTime:%@, current:%@, lastLoopTime:%@, currentTime:%@, gap:%@, duration:%@, dt:%@", @(extCost), @(self.preTargetFrameTime), @(current), @(self.lastLoopTime), @(currentTime), @(gap - kFPS60Rate), @(displayLink.duration), @(dt));
        }
    } else {
//        NSLog(@"间隔太短");
    }
    self.lastLoopTime = currentTime;
    self.preTargetFrameTime = displayLink.targetTimestamp;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"memory_test"];
    self.imageView = imageView;
    [self.view addSubview:imageView];
}
@end
