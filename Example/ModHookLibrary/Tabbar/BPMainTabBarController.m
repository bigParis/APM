//
//  BPMainTabBarController.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/3/8.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "BPMainTabBarController.h"
#import "BPViewController.h"
#import "BPWebViewController.h"

@interface BPMainTabBarController ()

@end

@implementation BPMainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initChildVCs];
}

- (void)initChildVCs{
    BPWebViewController *vc1 = [BPWebViewController new];
    vc1.view.backgroundColor = [UIColor yellowColor];
    vc1.tabBarItem.title = @"主页";
    // 默认图标
    vc1.tabBarItem.image = [UIImage new];
    // 选中图标
    vc1.tabBarItem.selectedImage = [UIImage new];

    BPViewController *vc2 = [BPViewController new];
    vc2.tabBarItem.title = @"个人";
    
    [self setViewControllers:@[vc1, vc2] animated:YES];
}

@end
