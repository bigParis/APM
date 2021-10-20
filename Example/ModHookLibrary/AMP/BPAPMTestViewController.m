//
//  BPAPMTestViewController.m
//  ModHookLibrary_Example
//
//  Created by 王飞 on 2021/10/20.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPAPMTestViewController.h"
#import <BPModInitFuncHook.h>

@interface BPAPMTestViewController ()

@end

@implementation BPAPMTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    double total = [BPModInitFuncHook total];
    NSLog(@"-%f", total);
}


@end
