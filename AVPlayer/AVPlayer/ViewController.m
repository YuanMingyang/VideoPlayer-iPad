//
//  ViewController.m
//  AVPlayer
//
//  Created by Yang on 2018/5/25.
//  Copyright © 2018年 Yang. All rights reserved.
//

#import "ViewController.h"
#import "MyVideoPlayer.h"

@interface ViewController ()
@property(nonatomic,strong)MyVideoPlayer *videoPlayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoPlayer = [MyVideoPlayer createPlayerWithFrame:CGRectMake(256, 192, 512, 384)];
    self.videoPlayer.videoUrl = [NSURL URLWithString:@"http://gtbl.ecloudmt.com/images/uploads/20171215/o_1c1cnahv9qhr9sm1ep91u9g1p967.mp4"];
    [self.view addSubview:self.videoPlayer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
