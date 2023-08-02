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
#import "NSObject+DataRaceScaner.h"
#import <Masonry/Masonry.h>
#import <Photos/Photos.h>
//#define VIEW_LEAK 1
//#define THREAD_LEAK 1
//#define BLOCK_LEAK 1
//#import "BPCppClass.h"
//#include <iostream>
//
//class YLKAudioEncodedFrameObserver: public IAudioEncodedFrameObserver {
//public:
//    __weak id<TestProtocol> delegate;
//    YLKAudioEncodedFrameObserver() {
//        std::cout << "YLKAudioEncodedFrameObserver Object alloc" << std::endl;
//    }
//    ~YLKAudioEncodedFrameObserver() {
//        std::cout << "YLKAudioEncodedFrameObserver Object released" << std::endl;
//    }
//};

@interface NSTestObjc : NSObject
@end

@implementation NSTestObjc

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

@end

@interface BPMemoryTestVC ()

/// 图片泄漏
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIImageView *imageView2;
@property (nonatomic, assign) BOOL imageLeakOpen;
@property (nonatomic, weak) UIButton *imageLeakBtn;

/// Block泄漏
#ifdef BLOCK_LEAK
@property (nonatomic, weak) UIButton *blockLeakBtn;
@property (nonatomic, assign) int testCount;
#endif
/// thread泄漏
#ifdef THREAD_LEAK
@property (nonatomic, weak) UIButton *threadLeakBtn;
@property (nonatomic, strong) NSThread *thread;
@property (nonatomic, strong) NSMutableArray *testArray;
@property (nonatomic, strong) BPContainer *container;
#endif
/// view引用泄漏
#ifdef VIEW_LEAK
@property (nonatomic, weak) UIButton *viewLeakBtn;
@property (nonatomic, strong) BPLeakHoldView *holdView;
@property (nonatomic, strong) BPLeakShowView *showView;
@property (nonatomic, assign) BOOL viewLeakOpen;
#endif
@end

@implementation BPMemoryTestVC
{
    dispatch_queue_t _dispatchQueue;
}
- (void)dealloc
{
    NSLog(@"%s", __func__);
#ifdef VIEW_LEAK
    if (self.viewLeakOpen) {
        [[BPLeakModelManager sharedManager] unRegisterModel:@"BPLeakHoldView"];
        [[BPLeakModelManager sharedManager] unRegisterModel:@"BPLeakShowView"];
    }
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    _dispatchQueue = dispatch_queue_create("bptest.queue", DISPATCH_QUEUE_SERIAL);
#ifdef VIEW_LEAK
    [self initManager];
#endif
    [self initViews];
#ifdef BLOCK_LEAK
    self.testCount = 0;
#endif
//    static YLKAudioEncodedFrameObserver *vob = new YLKAudioEncodedFrameObserver;
//    vob->delegate = self;
}

- (void)setupLeakImageView
{
    UIImageView *imageView = [[UIImageView alloc] init];
//    imageView.image = [self getCompressedImage];
//    imageView.image = [UIImage imageNamed:@"tianaijpeg2.jpeg"];
    imageView.image = [UIImage imageNamed:@"memory_test"];
//    imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"memory_test.jpeg" ofType:nil]];
    self.imageView = imageView;
    [self.view addSubview:imageView];
    
    UIImageView *imageView2 = [[UIImageView alloc] init];
//    imageView2.image = [UIImage imageNamed:@"tianai"];
//    imageView2.image = [UIImage imageNamed:@"tianai2webp.webp"];
//    imageView2.image = [UIImage imageNamed:@"tianaijpeg2.jpeg"];
    imageView2.image = [UIImage imageNamed:@"tianai2png.png"];
    self.imageView2 = imageView2;
    [self.view addSubview:self.imageView2];
}

- (void)requestAuthorization
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                // 用户已授权访问相册
                // 在这里调用保存图片到相册的方法
                break;
            case PHAuthorizationStatusDenied:
            case PHAuthorizationStatusRestricted:
                // 用户拒绝或限制了相册访问权限
                // 在这里处理相册访问权限被拒绝或限制的情况
                break;
            case PHAuthorizationStatusNotDetermined:
                // 用户还未决定是否授权相册访问权限
                // 在这里处理相册访问权限还未决定的情况
                break;
            default:
                break;
        }
    }];
}

- (void)writeImage
{
    
    for (int i = 0; i < 10000; ++i) {
        UIImage *image = [UIImage imageNamed:@"glasses"];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        });
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        // 保存失败
        NSLog(@"保存图片失败：%@", error.localizedDescription);
    } else {
        // 保存成功
        NSLog(@"保存图片成功");
    }
}

- (void)initViews
{
    self.view.backgroundColor = [UIColor yellowColor];

    UIButton *imageLeakBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageLeakBtn setTitle:@"图片泄漏按钮" forState:UIControlStateNormal];
    [imageLeakBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [imageLeakBtn setBackgroundColor:UIColor.cyanColor];
    [imageLeakBtn addTarget:self action:@selector(onImageLeakClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageLeakBtn];
    self.imageLeakBtn = imageLeakBtn;

#ifdef BLOCK_LEAK
    UIButton *blockLeakBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [blockLeakBtn setTitle:@"block泄漏" forState:UIControlStateNormal];
    [blockLeakBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [blockLeakBtn setBackgroundColor:UIColor.cyanColor];
    [blockLeakBtn addTarget:self action:@selector(onBlockLeakClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:blockLeakBtn];
    self.blockLeakBtn = blockLeakBtn;
#endif
    
#ifdef THREAD_LEAK
    UIButton *threadLeakBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [threadLeakBtn setTitle:@"thread内存泄漏" forState:UIControlStateNormal];
    [threadLeakBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [threadLeakBtn setBackgroundColor:UIColor.cyanColor];
    [threadLeakBtn addTarget:self action:@selector(onThreadLeakClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:threadLeakBtn];
    self.threadLeakBtn = threadLeakBtn;
#endif
    
    [self setupLeakImageView];
#ifdef VIEW_LEAK
    UIButton *viewLeakBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [viewLeakBtn setTitle:@"view泄漏按钮" forState:UIControlStateNormal];
    [viewLeakBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [viewLeakBtn setBackgroundColor:UIColor.cyanColor];
    [viewLeakBtn addTarget:self action:@selector(onViewLeakClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:viewLeakBtn];
    self.viewLeakBtn = viewLeakBtn;
    [self setupViewLeakView];
#endif
    
}

- (void)layoutImageLeakView
{
    self.imageView.frame = CGRectMake(0, 64, self.view.bounds.size.width * 0.5, 200);
    self.imageView2.frame = CGRectMake(self.view.bounds.size.width * 0.5, 64, self.view.bounds.size.width * 0.5, 200);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.imageLeakBtn.frame = CGRectMake((self.view.bounds.size.width - 200) * 0.5, 210 + 64, 200, 30);
#ifdef BLOCK_LEAK
    self.blockLeakBtn.frame = CGRectMake((self.view.bounds.size.width - 200) * 0.5, CGRectGetMaxY(self.imageLeakBtn.frame) + 10, 200, 30);
#endif
#ifdef THREAD_LEAK
    self.threadLeakBtn.frame = CGRectMake((self.view.bounds.size.width - 200) * 0.5, CGRectGetMaxY(self.blockLeakBtn.frame) + 10, 200, 30);
#endif
    
#ifdef VIEW_LEAK
    self.viewLeakBtn.frame = CGRectMake((self.view.bounds.size.width - 200) * 0.5, CGRectGetMaxY(self.threadLeakBtn.frame) + 10, 200, 30);
#endif
    if (self.imageLeakOpen) {
        [self layoutImageLeakView];
    }
}

#ifdef VIEW_LEAK
- (void)initManager
{
    BPLeakHoldView *holdView = [[BPLeakHoldView alloc] init];
    [[BPLeakModelManager sharedManager] registerModel:holdView forKey:@"BPLeakHoldView"];
    
    BPLeakShowView *showView = [[BPLeakShowView alloc] init];
    [[BPLeakModelManager sharedManager] registerModel:showView forKey:@"BPLeakShowView"];
}

- (void)setupViewLeakView
{
    self.showView = [[BPLeakModelManager sharedManager] getModelForKey:@"BPLeakShowView"];
    BPLeakHoldView *holdView = [[BPLeakModelManager sharedManager] getModelForKey:@"BPLeakHoldView"];
    self.showView.leakBlock = ^{
        NSLog(@"%@", holdView.name);
    };
    [self.view addSubview:self.showView];
}

- (void)onViewLeakClicked
{
    NSLog(@"%s", __func__);
    self.viewLeakOpen = YES;
    [self.showView testLeak];
}
#endif

#ifdef THREAD_LEAK
- (NSMutableArray *)testArray
{
    if (_testArray == nil) {
        _testArray = [NSMutableArray array];
    }
    return _testArray;
}

- (void)onThreadLeakClicked
{
    NSLog(@"%s", __func__);
    /* 内存升高，不是堆泄漏
    for (int i = 0; i < 1000000; i++) {
        [self.testArray addObject:@(i)];
    }
     */
    
    /*
     self.container = [[BPContainer alloc] init];
    for (int i = 0; i < 1000; i++) {
        @autoreleasepool {
            [self.container addModel:[[BPLeakModel alloc] initWithCount:i]];
        }
    }
//    执行thread会导致内存泄漏
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(loop) object:nil];
    [self.thread setName:@"com.walle.test"];
    [self.thread start];
     */
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
#endif

#ifdef BLOCK_LEAK
- (void)onBlockLeakClicked
{
    NSLog(@"%s", __func__);
    
//    NSLog(@"DEMO1: 以下操作会导致内存泄漏");
//    for (int i = 0; i < 10000; ++i) {
//        self.testCount++;
//        BPLeakModel *model = [[BPLeakModel alloc] init];
//        model.leakBlock = ^{
//            NSLog(@"model:%@", model);
//        };
//    }
    
    NSLog(@"DEMO2: 以下操作不会内存泄漏, 但leakblock回调数据为空");
    for (int i = 0; i < 10000; ++i) {
        BPLeakModel *model = [[BPLeakModel alloc] init];
        __weak __typeof(model) weak_model = model;
        model.leakBlock = ^{
            NSLog(@"model:%@", weak_model);
        };
    }
    
//    NSLog(@"DEMO3: 以下操作不会内存泄漏, 并且能捕获正确的数据, mallocBlock");
//    for (int i = 0; i < 10000; ++i) {
//        self.testCount++;
//        NSString *test = [NSString stringWithFormat:@"12889989d7fs8df12889989d7fs8df12889989d7fs8df12889989d7fs8df:%@", @(self.testCount)];
//        BPLeakModel *model = [[BPLeakModel alloc] init];
//        model.leakBlock = ^{
//            NSLog(@"test:%@", test);
//        };
//    }
}
#endif

- (void)onImageLeakClicked
{
//    self.imageLeakOpen = !self.imageLeakOpen;
//    [self.view setNeedsLayout];
//    [self.view layoutIfNeeded];
//    [self writeImage];
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
