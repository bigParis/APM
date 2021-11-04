//
//  BPSubView2.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/11/4.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPSubView2.h"
#import <Masonry/Masonry.h>

@interface BPSubView2 ()

@property (nonatomic, weak) UIView *childView2;

@end

@implementation BPSubView2

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
        [self setupLayout];
    }
    return self;
}

- (void)setupViews
{
    [super setupViews];
    UIView *childView2 = [[UIView alloc] init];
    childView2.backgroundColor = UIColor.greenColor;
    [self addSubview:childView2];
    self.childView2 = childView2;
}

- (void)setupLayout
{
    [super setupLayout];
    if (!self.redViewDisable) {
        [self.childView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.redView.mas_bottom).offset(10);
            make.left.mas_equalTo(self.redView);
            make.right.mas_equalTo(self.blueViewDisable ? self.redView : self.blueView);
            make.height.mas_equalTo(50);
        }];
    } else {
        [self.childView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.blueView.mas_bottom).offset(10);
            make.left.mas_equalTo(self.blueView);
            make.right.mas_equalTo(self.blueViewDisable ? self : self.blueView);
            make.height.mas_equalTo(50);
        }];
    }
}

@end
