//
//  BPViewController.m
//  ModHookLibrary
//
//  Created by wangfei5 on 09/24/2021.
//  Copyright (c) 2021 wangfei5. All rights reserved.
//

#import "BPViewController.h"
#import <ModHookLibrary/BPModInitFuncHook.h>

@interface BPViewController ()

@end

@implementation BPViewController

- (BOOL)testCode {
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    double total = [BPModInitFuncHook total];
    NSLog(@"-%f", total);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
