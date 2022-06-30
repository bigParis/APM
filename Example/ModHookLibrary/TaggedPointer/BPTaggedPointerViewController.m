//
//  BPTaggedPointerViewController.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/5/23.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "BPTaggedPointerViewController.h"

@interface BPTaggedPointerViewController ()

@end

@implementation BPTaggedPointerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSNumber *number = [NSNumber numberWithInt:1];
    NSString *string = [NSString stringWithFormat:@"热门话题"];
    NSString *string2 = @"热门话题";
    NSNumber *number2 = [NSNumber numberWithInteger:1];
    NSNumber *number3 = [NSNumber numberWithLongLong:-36028797018963967];
    NSNumber *number4 = [NSNumber numberWithLongLong:-36028797018963968];
    NSLog(@"%p %p %p %p %p", number, string, string2, number3, number4);
}
@end
