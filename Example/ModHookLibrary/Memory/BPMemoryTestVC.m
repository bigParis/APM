//
//  BPMemoryTestVC.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/11/5.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPMemoryTestVC.h"
#import "BPLeakModel.h"
#import "BPHoldModel.h"
#import "BPLeakModelManager.h"
#import "BPLeakHoldView.h"
#import "BPLeakShowView.h"
#import "BPContainer.h"
#import "BPLeakModel.h"

@interface BPMemoryTestVC ()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak)  UIButton *leakBtn;
@property (nonatomic, strong) BPLeakModel *leakModel;
@property (nonatomic, strong) BPLeakHoldView *holdView;
@property (nonatomic, strong) BPLeakShowView *showView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) BPContainer *container;
@property (nonatomic, strong) NSThread *thread;
@end

@implementation BPMemoryTestVC
- (void)dealloc
{
    NSLog(@"%s", __func__);
//    [[BPLeakModelManager sharedManager] unRegisterModel:@"BPLeakHoldView"];
//    [[BPLeakModelManager sharedManager] unRegisterModel:@"BPLeakShowView"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self initManager];
//    [self initViews];
    self.container = [[BPContainer alloc] init];

    for (int i = 0; i < 10; i++) {
        @autoreleasepool {
            [self.container addModel:[[BPLeakModel alloc] initWithCount:i]];
        }
    }

    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(loop) object:nil];
    [self.thread setName:@"com.walle.test"];
    [self.thread start];
    
}

- (void)loop
{
    while (true) {
        BPLeakModel *m = [self.container takeModel];
        [m increment];
        if (m) {
            [m increment];
        } else {
            break;
        }
    }
}

- (void)initViews
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [self getCompressedImage];
    self.imageView = imageView;
    [self.view addSubview:self.imageView];
    
    UIButton *leakBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [leakBtn setTitle:@"泄漏按钮" forState:UIControlStateNormal];
    [leakBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [leakBtn setBackgroundColor:UIColor.cyanColor];
    [leakBtn addTarget:self action:@selector(onLeakClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leakBtn];
    self.leakBtn = leakBtn;
    
    self.showView = [[BPLeakModelManager sharedManager] getModelForKey:@"BPLeakShowView"];
    BPLeakHoldView *holdView = [[BPLeakModelManager sharedManager] getModelForKey:@"BPLeakHoldView"];
    self.showView.leakBlock = ^{
        NSLog(@"%@", holdView.name);
    };
    [self.view addSubview:self.showView];
}

- (void)initManager
{
    BPLeakHoldView *holdView = [[BPLeakHoldView alloc] init];
    [[BPLeakModelManager sharedManager] registerModel:holdView forKey:@"BPLeakHoldView"];
    
    BPLeakShowView *showView = [[BPLeakShowView alloc] init];
    [[BPLeakModelManager sharedManager] registerModel:showView forKey:@"BPLeakShowView"];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.imageView.frame = CGRectMake(100, 200, 200, 200);
    self.imageView.center = self.view.center;
    self.leakBtn.frame = CGRectMake((self.view.bounds.size.width - 120) * 0.5, 120, 120, 30);
//    self.holdView.frame = CGRectMake(60, 100, 30, 30);
    self.showView.frame = CGRectMake(60, 160, 30, 30);
}

- (void)onLeakClicked
{
    /// Demo1
    
    [self.showView testLeak];
}

- (UIImage *)getCompressedImage
{
//    UIGraphicsImageRendererFormat *uiformat = format.uiformat;
    UIImage *image = [UIImage imageNamed:@"memory_test.jpeg"];
    CGSize size = CGSizeMake(200, 200);
    UIGraphicsImageRenderer *uirenderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    if (@available(iOS 10.0, tvOS 10.0, *)) {
        return [uirenderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            [image drawInRect:CGRectMake(0, 0, 200, 200)];
        }];
    } else {
        return nil;
    }
//    let render = UIGraphicsImageRenderer(size: bounds.size)
//       let image = render.image { context in
//           UIColor.blue.setFill()
//               let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: 20, height: 20))
//           path.addClip()
//           UIRectFill(bounds)
//        }
//        return image
}
@end
