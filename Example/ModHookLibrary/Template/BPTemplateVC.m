//
//  BPTemplateVC.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/10/28.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPTemplateVC.h"
#import "BPTemplateSub.h"

@interface BPTemplateVC ()

@end

@implementation BPTemplateVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    BPTemplateSub *subObj = [[BPTemplateSub alloc] init];
    NSLog(@"%@", [subObj getResult]);
}

@end
