//
//  BPSubView1.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/11/4.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPSubView1.h"
#import <Masonry/Masonry.h>

@interface BPSubView1 ()

@property (nonatomic, weak) UIView *childView1;

@end
@implementation BPSubView1

//- (instancetype)init
//{
//    NSLog(@"%s", __func__);
//    if (self = [super init]) {
//
//    }
//    return self;
//}

- (instancetype)initWithFrame:(CGRect)frame isGuide:(BOOL)isGuide
{
    NSLog(@"%s", __func__);
    if (isGuide) {
        self.redViewDisable = YES;
    } else {
        self.blueViewDisable = YES;
    }
    
//    self.blueViewEnable = YES;
    return [super initWithFrame:frame];
}

- (void)initConfig
{
    NSLog(@"%s", __func__);
    [super initConfig];
//    self.redViewEnable = YES;
//    self.blueViewEnable = YES;
}

- (void)setupViews
{
    NSLog(@"%s", __func__);
    [super setupViews];
    UIView *childView1 = [[UIView alloc] init];
    childView1.backgroundColor = UIColor.yellowColor;
    [self addSubview:childView1];
    self.childView1 = childView1;
}

- (void)setupLayout
{
    NSLog(@"%s", __func__);
    [super setupLayout];
    
    if (!self.redViewDisable) {
        [self.childView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.redView.mas_bottom).offset(10);
            make.left.mas_equalTo(self.redView);
            make.right.mas_equalTo(self.blueViewDisable ? self.redView : self.blueView);
            make.height.mas_equalTo(50);
        }];
    } else {
        [self.childView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.blueView.mas_bottom).offset(10);
            make.left.mas_equalTo(self.blueView);
            make.right.mas_equalTo(self.blueViewDisable ? self : self.blueView);
            make.height.mas_equalTo(50);
        }];
    }
    
}
@end
