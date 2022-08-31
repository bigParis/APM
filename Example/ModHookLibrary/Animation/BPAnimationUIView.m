//
//  BPAnimationUIView.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/8/31.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "BPAnimationUIView.h"
#import <Masonry/Masonry.h>

@interface BPAnimationUIView ()

@property (nonatomic, weak) UIView *targetContainer;
@property (nonatomic, weak) UIView *shadowView;
@property (nonatomic, weak) UIView *shadowView1;

@end

@implementation BPAnimationUIView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

- (void)initViews
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onViewClicked:)];
    [self addGestureRecognizer:tap];
    UIView *targetContainer = [[UIView alloc] init];
    targetContainer.backgroundColor = [UIColor redColor];
    [self addSubview:targetContainer];
    self.targetContainer = targetContainer;
    [self.targetContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self).offset(30);
        make.right.bottom.mas_equalTo(self).offset(-30);
    }];
    
    UIView *shadowView1 = [[UIView alloc] init];
    shadowView1.backgroundColor = [UIColor blackColor];
    self.shadowView1 = shadowView1;
    [targetContainer addSubview:shadowView1];
    [self.shadowView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(50);
        make.left.mas_equalTo(100+100);
        make.top.mas_equalTo(100+50+50);
    }];
    
    UIView *shadowView = [[UIView alloc] init];
    shadowView.layer.shadowOpacity = 0.16;
    shadowView.layer.shadowOffset = CGSizeMake(0, 0);
    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowView.backgroundColor = [UIColor whiteColor];
    [self addSubview:shadowView];
    self.shadowView = shadowView;

    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(50);
        make.left.mas_equalTo(100);
        make.top.mas_equalTo(100);
    }];
}

- (void)onViewClicked:(UITapGestureRecognizer *)tap
{
    static int x = 0;
    if (x %2 == 0) {
        [self showAniView];
    } else {
        [self hiddenView];
    }
    x++;
}

- (void)showAniView {
    self.shadowView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    self.shadowView.alpha = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.shadowView.alpha = 1;
        self.shadowView.transform = CGAffineTransformMakeScale(1.05, 1.05);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1f animations:^{
            self.shadowView.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            //  恢复原位
            self.shadowView.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)hiddenView {
    NSLog(@"shadowView1 center:%@", NSStringFromCGPoint(self.shadowView1.center));
    CGPoint realPoint = [self.shadowView1.superview convertPoint:self.shadowView1.center toView:self.shadowView.superview];
    NSLog(@"real center:%@", NSStringFromCGPoint(realPoint));
    [UIView animateWithDuration:3 animations:^{
        self.shadowView.center = realPoint;
        self.shadowView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        self.shadowView.transform = CGAffineTransformIdentity;
        self.shadowView.alpha = 0.0f;
    }];
}




@end
