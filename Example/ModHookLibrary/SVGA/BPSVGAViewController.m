//
//  BPSVGAViewController.m
//  ModHookLibrary_Example
//
//  Created by bigParis on 2021/12/8.
//  Copyright © 2021 wangfei5. All rights reserved.
//

#import "BPSVGAViewController.h"
#import <SVGAPlayer/SVGA.h>
#import <FLAnimatedImage/FLAnimatedImageView.h>
#import <SDWebImage/SDWebImage.h>

@interface BPSVGAViewController ()
@property (nonatomic, strong) SVGAPlayer *player;
@property (nonatomic, strong) UIImageView *gifView;
@end

@implementation BPSVGAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.gifView.frame = CGRectMake(200, 300, 43, 37);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view addSubview:self.gifView];
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"YmEzZjdhMjgtNmY1MC00MWQyLWE5NjEtMzZhN2M2ZTRlODJl" withExtension:@"gif"];
    NSURL *url = [NSURL URLWithString:@"https://emyfs.bs2cdn.yy.com/YmEzZjdhMjgtNmY1MC00MWQyLWE5NjEtMzZhN2M2ZTRlODJl.gif"];
    [self.gifView sd_setImageWithURL:fileUrl
                 placeholderImage:nil options:SDWebImageRefreshCached];
}

- (void)test1
{
    // Do any additional setup after loading the view.
    SVGAPlayer *player = [[SVGAPlayer alloc] initWithFrame:CGRectMake(200, 300, 30, 30)];
    self.player = player;
    [self.view addSubview:player]; // Add subview by yourself.
    
    NSString *resPath = [[NSBundle mainBundle] pathForResource:@"index_anchor_info_live_animation" ofType:@"svga"];
    
    if (!resPath || resPath.length <= 0) {
        return;
    }

    NSData *data = [[NSData alloc] initWithContentsOfFile:resPath];
    SVGAParser *parser = [[SVGAParser alloc] init];
    __weak SVGAPlayer *aPlayer = self.player;
    [parser parseWithData:data cacheKey:@"index_anchor_info_live_animation" completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
        if (videoItem) {
            [aPlayer setVideoItem:videoItem];
            [aPlayer startAnimation];
        }
        } failureBlock:^(NSError * _Nonnull error) {
            NSLog(@"error:%@", error);
    }];
}

- (UIImageView *)gifView
{
    if (_gifView == nil) {
        _gifView = [[UIImageView alloc] init];
    }
    return _gifView;
}
@end
