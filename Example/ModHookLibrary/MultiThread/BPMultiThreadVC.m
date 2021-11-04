//
//  BPMultiThreadVC.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/10/26.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPMultiThreadVC.h"
#import "BPMultiManager.h"

@interface BPMultiThreadVC ()
@property (nonatomic, weak) UIButton *beginBtn;
@property (nonatomic, weak) UIButton *endBtn;
@end

@implementation BPMultiThreadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    // Do any additional setup after loading the view.
}

- (void)initViews
{
    UIButton *beginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [beginBtn setTitle:@"开始" forState:UIControlStateNormal];
    [beginBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [beginBtn setBackgroundColor:UIColor.greenColor];
    [beginBtn addTarget:self action:@selector(onBeginBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.beginBtn = beginBtn;
    [self.view addSubview:beginBtn];
    
    UIButton *endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [endBtn setTitle:@"结束" forState:UIControlStateNormal];
    [endBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [endBtn setBackgroundColor:UIColor.greenColor];
    [endBtn addTarget:self action:@selector(onEndBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.endBtn = endBtn;
    [self.view addSubview:endBtn];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.beginBtn.frame = CGRectMake(100, 200, 100, 30);
    self.endBtn.frame = CGRectMake(100, 300, 100, 30);
    
}

- (void)onBeginBtnClicked:(UIButton *)sender
{
    [[BPMultiManager sharedManager] beginTask];
}

- (void)onEndBtnClicked:(UIButton *)sender
{
    [[BPMultiManager sharedManager] cancelAll];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
}
@end
