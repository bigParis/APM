//
//  BPMemoryTestVC.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/11/5.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPMemoryTestVC.h"

@interface BPMemoryTestVC ()

@property (nonatomic, weak) UIImageView *imageView;
@end

@implementation BPMemoryTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imageView = [[UIImageView alloc] init];
//    imageView.image = [UIImage imageNamed:@"memory_test.jpeg"];
    imageView.image = [self getCompressedImage];

    self.imageView = imageView;
    [self.view addSubview:self.imageView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.imageView.frame = CGRectMake(100, 200, 200, 200);
    self.imageView.center = self.view.center;
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
