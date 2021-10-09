//
//  BPViewController.m
//  ModHookLibrary
//
//  Created by wangfei5 on 09/24/2021.
//  Copyright (c) 2021 wangfei5. All rights reserved.
//

#import "BPViewController.h"
#import <BPModInitFuncHook.h>
#import <BPTestCode1.h>
@interface BPViewController ()

@end

@implementation BPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    double total = [BPModInitFuncHook total];
    BPTestCode1 *obj1 = [[BPTestCode1 alloc] init];
    [obj1 testCode1];
    NSLog(@"-%f", total);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
