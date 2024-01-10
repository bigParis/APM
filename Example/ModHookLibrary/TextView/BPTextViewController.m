//
//  BPTextViewController.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2024/1/8.
//  Copyright © 2024 wangfei5. All rights reserved.
//

#import "BPTextViewController.h"

@interface BPTextViewController ()

@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, strong) CAGradientLayer *backgroundLayer;
@end

@implementation BPTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.textView.frame = CGRectMake(100, 250, self.view.bounds.size.width - 200, 100);
    self.backgroundLayer.frame = CGRectMake(0, 70, self.view.bounds.size.width - 200., 30);
}

- (void)initViews
{
    UITextView *textView = [[UITextView alloc] init];
    textView.editable = NO;
    textView.scrollEnabled = YES;
    textView.bounces = NO;
//    textView.alwaysBounceVertical = YES;
//    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.showsVerticalScrollIndicator = NO;
//    contentView.contentInset = UIEdgeInsetsZero;
    textView.textContainerInset = UIEdgeInsetsZero;
    textView.textContainer.lineFragmentPadding = 0;
    textView.textColor = [UIColor whiteColor];
    textView.backgroundColor = [UIColor grayColor];
    textView.textAlignment = NSTextAlignmentLeft;
    textView.font = [UIFont systemFontOfSize:13.f weight:500];
    [textView setText:@"我很长惆怅长岑长擦擦乐山大佛姜辣素大飞机第三方框架阿里斯顿咖啡机了水电费离开家阿里斯顿开发机啦打扫房间阿里时代峰峻了塑料袋副科级拉胯大姐夫婆婆万恶日power婆婆我儿颇为肉我饿陪我饿哦日婆婆破收到发票哦覅破配件哦苏东坡佛平时到付件家婆给排水到付件破拒收到付评价啊对皮肤就怕大家富婆啊结算单富婆啊结算单富婆假的富婆家苏东坡佛教阿帕佛教 阿婆是的哦近防炮结算单富婆啊剪短发搜到附件破大姐夫啊符号的反间谍法\n破解东风破阿道夫奥几点睡发泡世纪东方搜到附件"];
    [self.view addSubview:textView];
    self.textView = textView;
    NSString *tagString = [NSString stringWithFormat:@"%x", textView];
    NSInteger tagValue = [tagString integerValue];
    textView.tag = 12;
                NSString * temp10 = [NSString stringWithFormat:@"%lu",strtoul([tagString UTF8String],0,16)];
                NSLog(@"心跳数字 10进制 %@",temp10);
                //转成数字
                int cycleNumber = [temp10 intValue];
                NSLog(@"心跳数字 ：%d",cycleNumber);
    CAGradientLayer *backgroundLayer = [CAGradientLayer layer];
    backgroundLayer.colors = @[(id)[[[UIColor grayColor] colorWithAlphaComponent:0.5f] CGColor],
                                    (id)[[[UIColor grayColor] colorWithAlphaComponent:1.f] CGColor]];
    backgroundLayer.startPoint = CGPointMake(.5, 0);
    backgroundLayer.endPoint = CGPointMake(.5, 1);
    self.backgroundLayer = backgroundLayer;
    [self.textView.layer addSublayer:backgroundLayer];
    
}
@end
