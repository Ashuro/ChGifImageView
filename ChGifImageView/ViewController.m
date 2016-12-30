//
//  ViewController.m
//  ChGifImageView
//
//  Created by Ashuro on 2016/12/26.
//  Copyright © 2016年 Ashuro. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<ChGifImageViewDelegate>;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //使用URL创建
    ChGifImageView *demo1 = [[ChGifImageView alloc] initWithFrame:CGRectMake(0, 20, 100, 100) withURL:@"http://img05.tooopen.com/products/20141215/EC17D785-1E06-F2C9-8A4B-4CBE9D0C8B08.gif"];
    [self.view addSubview:demo1];
    
    //使用Gif创建
    ChGifImageView *demo2 = [[ChGifImageView alloc] initWithFrame:CGRectMake(100, 20, 100, 100) withImageName:@"demo2" withCacheType:GifCacheDefault withTap:^(ChGifImageView *gifImageView) {
        //动画
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.values = @[@1.0,@1.15,@0.95,@1.10,@0.95,@1.02,@1.0];
        animation.duration = 1;
        animation.calculationMode = kCAAnimationCubic;
        [gifImageView.layer addAnimation:animation forKey:nil];
    }];
    [self.view addSubview:demo2];
    
    //使用frame创建，并后续提供【图片名称】的数据源
    ChGifImageView *demo3 = [[ChGifImageView alloc] initWithFrame:CGRectMake(200, 20, 100, 100)];
    NSMutableArray *picNameArray = [NSMutableArray arrayWithCapacity:900];
    
    [demo3 speedLoopWithCount:900 withCallBack:^(NSInteger index) {
        NSString * imgName = [NSString stringWithFormat:@"diqiu1 (%ld)",(long)index+1];
        [picNameArray addObject:imgName];
    } withComplete:^(id obj) {
        NSLog(@"over");
        [demo3 setImageNameArray:picNameArray withImageType:@"png"];
        [self.view addSubview:demo3];
    }];
    demo3.speedValue = 0.001;
    
    //通过xib创建
    [self.demo4 setImageName:@"demo3" withRefreshType:GifChcheRefresh];
    self.demo4.ChGifImageViewDelegate = self;
}

#pragma mark - ChGifImageView Delegate
- (void)didTapImageView:(ChGifImageView *)gifImageView {
    //动画
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@1.0,@1.15,@0.95,@1.10,@0.95,@1.02,@1.0];
    animation.duration = 1;
    animation.calculationMode = kCAAnimationCubic;
    [gifImageView.layer addAnimation:animation forKey:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
