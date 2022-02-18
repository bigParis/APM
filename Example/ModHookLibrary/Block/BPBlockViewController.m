//
//  BPBlockViewController.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/12/30.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPBlockViewController.h"

//这是一个简化代码
@interface TestObj: NSObject

-(NSString*)testString;

-(NSInteger)length;

@end

@implementation TestObj
- (NSInteger)length
{
    return 10;
}

//- (NSString *)testString
//{
//    return @"1234567";
//}
@end

@interface BPBlockViewController ()

@end

@implementation BPBlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self testCrash];
    BOOL isHello = YES;
    int x = 50;
    NSString *test = @"123";
    
    if (isHello && (x > 10) && [test isEqualToString:@"123"]) {
        NSLog(@"");
    } else {
        NSLog(@"failed");
    }
}

- (void)test1
{
    __weak __typeof(self) weakSelf = self;
    [self blockCompleted:^{
        [self printThx];
//        __strong __typeof(self) strongSelf = weakSelf;
//        [strongSelf printThx];
    } name:nil];
}

- (void)printThx
{
    NSLog(@"thx");
}

- (void)blockCompleted:(dispatch_block_t)completed name:(NSString *)name
{
    if (name == nil) {
        return;
    }
    
    if (completed) {
        completed();
    }
}

- (void)testCrash
{
    [self fn:[TestObj new] queue:dispatch_get_global_queue(0, 0)];
}

//代码片段
-(void)fn:(TestObj*)testObj queue:(dispatch_queue_t)queue {
    dispatch_async(queue, ^{
        @autoreleasepool {
              if ([testObj length] != 0) {
                  NSString *suffix = [testObj testString];
                  const static int len = 4;
                  if (suffix.length > len) {
                      suffix = [suffix substringToIndex:len];
                  }
              }
        }
    });
}
@end
