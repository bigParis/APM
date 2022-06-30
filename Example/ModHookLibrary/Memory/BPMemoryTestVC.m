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
#import <objc/runtime.h>

@interface NSTestObjc : NSObject
@end

@implementation NSTestObjc

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

@end

@interface BPMemoryTestVC ()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak)  UIButton *leakBtn;
@property (nonatomic, strong) BPLeakModel *leakModel;
@property (nonatomic, strong) BPLeakHoldView *holdView;
@property (nonatomic, strong) BPLeakShowView *showView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) BPContainer *container;
@property (nonatomic, strong) NSThread *thread;
@property (nonatomic, weak) UIImageView *imageView2;
@property (nonatomic, weak) UISwitch *switchView;
@property (nonatomic, weak) UIButton *lanscapeBtn;
@end

@implementation BPMemoryTestVC
{
    dispatch_queue_t _dispatchQueue;
}
- (void)dealloc
{
    NSLog(@"%s", __func__);
//    [[BPLeakModelManager sharedManager] unRegisterModel:@"BPLeakHoldView"];
//    [[BPLeakModelManager sharedManager] unRegisterModel:@"BPLeakShowView"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    _dispatchQueue = dispatch_queue_create("bptest.queue", DISPATCH_QUEUE_SERIAL);
//    [self initManager];
    [self initViews];
    self.container = [[BPContainer alloc] init];

//    for (int i = 0; i < 10; i++) {
//        @autoreleasepool {
//            [self.container addModel:[[BPLeakModel alloc] initWithCount:i]];
//        }
//    }

//    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(loop) object:nil];
//    [self.thread setName:@"com.walle.test"];
//    [self.thread start];
    
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
//    UISwitch *switchView = [[UISwitch alloc] init];
////    switchView.layer.cornerRadius = 20.f;
//    switchView.layer.masksToBounds = YES;
//    switchView.tintColor = [UIColor greenColor];
//    switchView.onTintColor = [UIColor redColor];
//    switchView.thumbTintColor = [UIColor whiteColor];
//    switchView.backgroundColor = [UIColor yellowColor];
//    switchView.transform = CGAffineTransformMakeScale(25/51.f, 14/31.f);
    
//    self.switchView = switchView;
//    [self.view addSubview:switchView];
    UIImageView *imageView = [[UIImageView alloc] init];
//    imageView.image = [self getCompressedImage];
//    imageView.image = [UIImage imageNamed:@"tianaijpeg2.jpeg"];
    imageView.image = [UIImage imageNamed:@"memory_test.jpeg"];
    self.imageView = imageView;
    [self.view addSubview:self.imageView];
    
    UIImageView *imageView2 = [[UIImageView alloc] init];
//    imageView2.image = [UIImage imageNamed:@"tianai"];
//    imageView2.image = [UIImage imageNamed:@"tianai2webp.webp"];
    imageView2.image = [UIImage imageNamed:@"tianaijpeg2.jpeg"];
//    imageView2.image = [UIImage imageNamed:@"tianai2png.png"];
    self.imageView2 = imageView2;
    [self.view addSubview:self.imageView2];
    
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
    
    UIButton *lanscapeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lanscapeBtn.backgroundColor = [UIColor redColor];
    [lanscapeBtn setTitle:@"泄\n漏" forState:UIControlStateNormal];
    lanscapeBtn.titleLabel.numberOfLines = 0;
    lanscapeBtn.titleLabel.font = [UIFont systemFontOfSize:12.f];
    [self.view addSubview:lanscapeBtn];
    self.lanscapeBtn = lanscapeBtn;
    
    UILabel *shadowLabel = [[UILabel alloc] init];
    shadowLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
//    shadowLabel.layer.shadowRadius = 20;
    shadowLabel.text = @"layer层设置阴影";
//    shadowLabel.backgroundColor = [UIColor blackColor];
//    shadowLabel.textColor = [UIColor redColor];
    shadowLabel.shadowColor = [UIColor redColor];
    shadowLabel.shadowOffset = CGSizeMake(0, -3);
    shadowLabel.frame = CGRectMake(200, 500, 100, 30);
    [self.view addSubview:shadowLabel];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(100, 150, 200, 50)];
        label2.text = @"layer层设置阴影";
    label2.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    label2.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.7].CGColor;
    label2.layer.shadowOpacity = 0.6f;
    label2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
    [self.view addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(100, 250, 200, 50)];
    label3.text = @"layer层设置阴影-无模糊半径";
    label3.shadowOffset = CGSizeMake(0.0f, -8.0f);
//    label3.layer.shadowRadius  = 2.f;
    label3.layer.shadowColor = [UIColor redColor].CGColor;
    label3.layer.shadowOpacity = 0.5f;
    label3.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
    [self.view addSubview:label3];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(100, 350, 200, 50)];
    label4.text = @"layer层设置阴影-无模糊半径-透明度0.1";
    label4.shadowOffset = CGSizeMake(0.0f, 1.0f);
//    label3.layer.shadowRadius  = 2.f;
    label4.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    label4.layer.shadowOpacity = 0.1f;
    label4.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
    [self.view addSubview:label4];
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
//    self.imageView.frame = CGRectMake(0, 64, self.view.bounds.size.width * 0.5, 200);
//    self.leakBtn.frame = CGRectMake((self.view.bounds.size.width - 120) * 0.5, 120, 120, 30);
////    self.holdView.frame = CGRectMake(60, 100, 30, 30);
//    self.showView.frame = CGRectMake(60, 160, 30, 30);
//
//    self.imageView2.frame = CGRectMake(self.view.bounds.size.width * 0.5, 64, self.view.bounds.size.width * 0.5, 200);
    self.switchView.frame = CGRectMake(200, 200, 100, 40);
    self.lanscapeBtn.frame = CGRectMake(200, 300, 40, 38);
}

- (void)onLeakClicked
{
    /// Demo1
    
//    [self.showView testLeak];
//    _dispatchQueue = dispatch_queue_create("bptest.queue", DISPATCH_QUEUE_SERIAL);
//    dispatch_async(_dispatchQueue, ^{
//        NSTestObjc *testModel = [[NSTestObjc alloc] init];
//        NSLog(@"testModel:%p", testModel);
//    });
//    IMP imp = imp_implementationWithBlock(^(id obj, NSString *str) {
//        NSLog(@"%@", str);
//    });
//    class_addMethod(NSTestObjc.class, @selector(testBlock:), imp, "v@:@");
//
//    NSTestObjc *runtime = [[NSTestObjc alloc] init];
//    [runtime performSelector:@selector(testBlock:) withObject:@"hello world!"];
//    NSString *test = @"1243";
//    do {
//        if ([test isEqualToString:@"1243"]) {
//            break;
//        } else {
//            NSLog(@"test:%@", test);
//        }
//    } while(0);
//    NSLog(@"come here");
}

- (UIImage *)getCompressedImage
{
//    UIGraphicsImageRendererFormat *uiformat = format.uiformat;
    UIImage *image = [UIImage imageNamed:@"memory_test.jpeg"];
    
    CGSize size = CGSizeMake(2000, 3000);
    UIGraphicsImageRenderer *uirenderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    if (@available(iOS 10.0, tvOS 10.0, *)) {
        return [uirenderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            [image drawInRect:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
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
