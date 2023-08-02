//
//  BPTaggedPointerViewController.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/5/23.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "BPTaggedPointerViewController.h"

static NSString *test = @"123";

@interface BPTaggedPointerViewController ()
@property (nonatomic, copy) dispatch_block_t testBlock;
@property (nonatomic, copy) NSString *aString;

@property (nonatomic, assign) CGRect rect;

@end

@implementation BPTaggedPointerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.rect = CGRectZero;
    NSLog(@"self.rect:%@", @(self.rect));
    NSString *str = NSStringFromCGRect(self.rect);
    UILabel *label = [[UILabel alloc] init];
    [self.view addSubview:label];
    label.text = str;
    label.frame = CGRectMake(100, 100, 200, 30);
    CGFloat x = 3.14f;
    CGFloat y = 2 * x;
    CGFloat z = 2 * y;
    int yy = 3;
    NSLog(@"Address of x: %p,y :%p, z:%p, yy:%p", &x, &y, &z, &yy);
    if (x == 0) {
        NSLog(@"wrong");
    } else {
        NSLog(@"right");
    }
//    NSString *other = @"910291021";
//    __weak typeof(other) weak_other = other;
//    __weak typeof(test) weak_test = test;
//    NSLog(@"%p-%p", weak_test, test);
//    NSLog(@"%p-%p", weak_other, other);
//    __weak typeof(self) weakSelf = self;
    
//    self.testBlock = ^{
//        weakSelf.aString = @"flaksdfj";
//    };
    // Do any additional setup after loading the view.
}

+ (void)test
{
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch");
    UIView *view = nil;

    if (view) {
        NSLog(@"已创建");
        return;
    }
    UIView *temp = [[UIView alloc] init];
    view = temp;
    view.frame = CGRectMake(100, 200, 100, 200);
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor grayColor];
    [self.view addSubview:view];
    NSLog(@"创建%p", view);
}
@end
