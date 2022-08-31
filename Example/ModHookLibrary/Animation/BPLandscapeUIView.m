//
//  BPLandscapeUIView.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/8/31.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "BPLandscapeUIView.h"

@interface BPLandscapeUIView ()

@property (nonatomic, weak) UIButton *lanscapeBtn;
@property (nonatomic, weak) UILabel *shadowLabel;
@property (nonatomic, weak) UILabel *label2;
@property (nonatomic, weak) UILabel *label3;
@property (nonatomic, weak) UILabel *label4;

@end

@implementation BPLandscapeUIView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

- (void)initViews
{
    UIButton *lanscapeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lanscapeBtn.backgroundColor = [UIColor redColor];
    lanscapeBtn.titleLabel.numberOfLines = 0;
    lanscapeBtn.titleLabel.font = [UIFont systemFontOfSize:12.f];
    [self addSubview:lanscapeBtn];
    self.lanscapeBtn = lanscapeBtn;
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = 10;
    paraStyle.hyphenationFactor = 1.0;
    NSDictionary *dic = @{
        NSFontAttributeName:[UIFont systemFontOfSize:12.f],
        NSParagraphStyleAttributeName:paraStyle,
    };
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:@"泄\n漏\n泄\n泄" attributes:dic];
    [lanscapeBtn setAttributedTitle:attributeStr forState:UIControlStateNormal];
    
    UILabel *shadowLabel = [[UILabel alloc] init];
    self.shadowLabel = shadowLabel;
    shadowLabel.numberOfLines = 0;
    shadowLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
    [self addSubview:shadowLabel];
    shadowLabel.attributedText = attributeStr;
    
    UILabel *label2 = [[UILabel alloc] init];
        label2.text = @"layer层设置阴影-下阴影(+2)";
    self.label2 = label2;
    label2.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    label2.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.7].CGColor;
    label2.layer.shadowOpacity = 0.6f;
    label2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
    [self addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] init];
    self.label3 = label3;
    label3.text = @"layer层设置阴影-无模糊半径-上阴影(-8)";
    label3.shadowOffset = CGSizeMake(0.0f, -8.0f);
    label3.layer.shadowColor = [UIColor redColor].CGColor;
    label3.layer.shadowOpacity = 0.5f;
    label3.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
    [self addSubview:label3];
    
    UILabel *label4 = [[UILabel alloc] init];
    self.label4 = label4;
    label4.text = @"layer层设置阴影-无模糊半径-透明度0.1-下阴影(1)";
    label4.shadowOffset = CGSizeMake(0.0f, 1.0f);
    label4.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    label4.layer.shadowOpacity = 0.1f;
    label4.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
    [self addSubview:label4];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.lanscapeBtn.frame = CGRectMake(100, 0, 40, 100);
    self.shadowLabel.frame = CGRectMake(150, 0, 40, 100);
    self.label2.frame = CGRectMake(50, 100, 400, 50);
    self.label3.frame = CGRectMake(50, 160, 400, 50);
    self.label4.frame = CGRectMake(50, 220, 400, 50);
}
@end
