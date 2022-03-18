//
//  BPRuntimeViewController.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2022/3/2.
//  Copyright © 2022 wangfei5. All rights reserved.
//

#import "BPRuntimeViewController.h"
#import "BPRuntimeExcutor.h"

void testCovid() {
    long long hitCovidCount = 0;
    BOOL someoneHitCovid = YES;
    while(1) {
        if (someoneHitCovid) {
            hitCovidCount++;
        }
        
        if (hitCovidCount >= 10000) {
            hitCovidCount = hitCovidCount * 100;
            printf("省长下马--等死🙈");
        } else if (hitCovidCount >= 1000) {
            hitCovidCount = hitCovidCount * 10;
            printf("封省--需要八方支援--建方舱😭");
        } else if (hitCovidCount >= 100) {
            hitCovidCount = hitCovidCount * 5;
            printf("封城市--市长下马😠");
        } else if (hitCovidCount >= 10) {
            hitCovidCount = hitCovidCount * 100;
            printf("隐瞒😏");
        } else if (hitCovidCount > 0) {
            for (int i = 0; i < INT_MAX; ++i) {
                printf("打疫苗第%d针🥴", i);
            }
        } else {
            printf("出去玩😄");
            break;
        }
    }
}

@interface BPRuntimeViewController ()

@end

@implementation BPRuntimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    int x = 1 << 12;
    NSLog(@"x=%@", @(x));
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSUInteger tabIndex = 1;
    BOOL animated = NO;
    BPRuntimeExcutor *executor = [[BPRuntimeExcutor alloc] init];
    SEL selector = @selector(scrollToIndex:animation:);
    NSMethodSignature *methodSign = [executor methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSign];
    invocation.target = executor;
    invocation.selector = selector;
    [invocation setArgument:&tabIndex atIndex:2];
    [invocation setArgument:&animated atIndex:3];
    [invocation invoke];
}
@end
