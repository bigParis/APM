//
//  BPAnimationVC.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/8/31.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "BPAnimationVC.h"
#import "BPLandscapeUIView.h"
#import "BPAnimationUIView.h"

@interface BPAnimationVC ()

@property (nonatomic, weak) BPLandscapeUIView *landscapeView;
@property (nonatomic, weak) BPAnimationUIView *animationView;

@end

@implementation BPAnimationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
}

- (void)initViews
{
    BPLandscapeUIView *landscapeView = [[BPLandscapeUIView alloc] init];
    [self.view addSubview:landscapeView];
    self.landscapeView = landscapeView;
    
    BPAnimationUIView *animationView = [[BPAnimationUIView alloc] init];
    [self.view addSubview:animationView];
    self.animationView = animationView;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.landscapeView.frame = CGRectMake(0, 64, self.view.bounds.size.width, 300);
    self.animationView.frame = CGRectMake(CGRectGetMinX(self.landscapeView.frame), CGRectGetMaxY(self.landscapeView.frame), CGRectGetWidth(self.landscapeView.frame), 500);
}
@end
