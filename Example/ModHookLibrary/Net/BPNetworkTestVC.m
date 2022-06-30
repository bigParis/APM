//
//  BPNetworkTestVC.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/10/22.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPNetworkTestVC.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import <SDWebImage/SDWebImage.h>

@interface BPNetworkTestVC ()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIImageView *alphaImage;
@end

@implementation BPNetworkTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
}

- (void)initViews
{
    UIImageView *imageView = [[UIImageView alloc] init];
    self.imageView = imageView;
    [self.view addSubview:self.imageView];
    
    UIImageView *alphaImage = [[UIImageView alloc] init];
    self.alphaImage = alphaImage;
    [self.view addSubview:alphaImage];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, 200, 200);
    self.imageView.center = self.view.center;
    self.alphaImage.frame = CGRectMake(0, 0, 100, 30);
    self.alphaImage.center = self.view.center;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.jj20.com%2Fup%2Fallimg%2F1114%2F060421091316%2F210604091316-2-1200.jpg&refer=http%3A%2F%2Fimg.jj20.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1637464797&t=e11afa136f946d0979903b6a9e11997f"]
                 placeholderImage:nil options:SDWebImageRefreshCached];
    [self.alphaImage setImage:[UIImage imageNamed:@"Ybear_Color_2k.png"]];
}

- (void)testCode
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    sessionManager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", @"image/jpeg", nil];

//    NSURL *URL = [NSURL URLWithString:@"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.jj20.com%2Fup%2Fallimg%2F1114%2F060421091316%2F210604091316-2-1200.jpg&refer=http%3A%2F%2Fimg.jj20.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1637464265&t=c20b0708b67b4b111c83ea61bf736d8d"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [sessionManager GET:@"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.jj20.com%2Fup%2Fallimg%2F1114%2F060421091316%2F210604091316-2-1200.jpg&refer=http%3A%2F%2Fimg.jj20.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1637464797&t=e11afa136f946d0979903b6a9e11997f" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"--progress:%@", @(downloadProgress.completedUnitCount * 1.f /downloadProgress.totalUnitCount));
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"success");
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"failure:%@", error);
        }];
//    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@", error);
//        } else {
//            NSLog(@"%@ %@", response, responseObject);
//        }
//    }];
//    [dataTask resume];
}

@end
