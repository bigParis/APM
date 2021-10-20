//
//  BPTableViewCell.m
//  ModHookLibrary_Example
//
//  Created by 王飞 on 2021/10/21.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPTableViewCell.h"

@interface BPTableViewCell ()

@property (nonatomic, weak) UILabel *content;
@end

@implementation BPTableViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

- (void)initViews
{
    UILabel *content = [[UILabel alloc] init];
    content.textAlignment = NSTextAlignmentCenter;
    content.textColor = UIColor.blackColor;
    [content setFont:[UIFont systemFontOfSize:13.f]];
    [self.contentView addSubview:content];
    self.content = content;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.content.frame = self.contentView.bounds;
}

- (void)setDesc:(NSString *)desc
{
    self.content.text = desc;
}

@end
