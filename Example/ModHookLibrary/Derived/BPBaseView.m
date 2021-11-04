//
//  BPBaseView.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/11/4.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPBaseView.h"

@interface BPBaseView()



@end

@implementation BPBaseView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initConfig];
        [self setupViews];
        [self setupLayout];
    }
    return self;
}

- (void)initConfig
{
    NSLog(@"%s", __func__);
}

- (void)setupViews
{
    NSLog(@"%s", __func__);
    
    self.backgroundColor = UIColor.grayColor;
    
    if (!self.redViewDisable) {
        UIView *redView = [[UIView alloc] init];
        redView.backgroundColor = UIColor.redColor;
        [self addSubview:redView];
        self.redView = redView;
    }
    
    if (!self.blueViewDisable) {
        UIView *blueView = [[UIView alloc] init];
        blueView.backgroundColor = UIColor.blueColor;
        [self addSubview:blueView];
        self.blueView = blueView;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.redView.frame = CGRectMake(20, 100, 50, 50);
    self.blueView.frame = CGRectMake(self.bounds.size.width - 20 - 50, 100, 50, 50);
}

- (void)setupLayout
{
    NSLog(@"%s", __func__);
}
@end
