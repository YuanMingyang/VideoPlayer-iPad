//
//  MyVideoPlayer.m
//  AVPlayer
//
//  Created by Yang on 2018/5/25.
//  Copyright © 2018年 Yang. All rights reserved.
//

#import "MyVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface MyVideoPlayer ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UIView *touchView;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UIButton *stopOrPlayBtn;
@property (weak, nonatomic) IBOutlet UIButton *bigOrSmallBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlide;

- (IBAction)stopOrPlayBtnClick:(UIButton *)sender;
- (IBAction)bigOrSmallBtnClick:(UIButton *)sender;
- (IBAction)progressSlideValueChanged:(UISlider *)sender;

@property(nonatomic,strong)AVPlayer *player;//播放器
@property(nonatomic,strong)AVPlayerItem *playerItem;//播放单元
@property(nonatomic,strong)AVPlayerLayer *playerLayer;//播放界面

@property(nonatomic,assign)CGRect originFrame;//初始frame
@property(nonatomic,strong)NSTimer *statusTimer;//控制底部状态栏定时器

@end


@implementation MyVideoPlayer
static MyVideoPlayer *videoPlayer;
-(void)awakeFromNib{
    [super awakeFromNib];
    self.touchView.userInteractionEnabled = YES;
    //添加点击事件
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [self.touchView addGestureRecognizer:singleTap];
    [self.touchView addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self createStatusTimer];
    [self showActivity];
    
    [self.progressSlide setThumbImage:[UIImage imageNamed:@"prPoint"] forState:UIControlStateNormal];
}


#pragma mark -- 内部方法
//单击屏幕
-(void)singleTap{
    NSLog(@"单击");
    if (self.bottomBar.hidden) {
        [self showBottomBar];
    }else{
        [self hidenBottomBar];
    }
}
//双击屏幕
-(void)doubleTap{
    NSLog(@"双击");
    [self createStatusTimer];
    if (self.stopOrPlayBtn.selected) {
        [self.player play];
    }else{
        [self.player pause];
    }
    self.stopOrPlayBtn.selected = !self.stopOrPlayBtn.selected;
}

//创建底部状态栏定时器
-(void)createStatusTimer{
    [self deleteStatusTimer];
    self.statusTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hidenBottomBar) userInfo:nil repeats:NO];
}
//删除底部状态栏定时器
-(void)deleteStatusTimer{
    [self.statusTimer invalidate];
    self.statusTimer = nil;
}
//隐藏底部bar
-(void)hidenBottomBar{

    self.bottomBar.hidden = YES;
    [self deleteStatusTimer];
}
//显示底部bar
-(void)showBottomBar{
    self.bottomBar.hidden = NO;
    [self createStatusTimer];
}
//显示activity
-(void)showActivity{
    self.activity.hidden = NO;
    [self.activity startAnimating];
    
}
//隐藏activity
-(void)hidenActivity{
    self.activity.hidden = YES;
    [self.activity stopAnimating];
    
}
//创建播放器
-(void)createAVPlayer{
    self.playerItem = [AVPlayerItem playerItemWithURL:self.videoUrl];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.bounds;
    [self.layer addSublayer:self.playerLayer];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];//监听播放状态
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];//监听缓存不够视频加载不出来
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];//监听缓存足够视频加载出来
    [self.player play];
    
    __weak typeof(self)weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:nil usingBlock:^(CMTime time) {
        AVPlayerItem *playerItem = weakSelf.playerItem;
        NSTimeInterval currentTime = playerItem.currentTime.value/playerItem.currentTime.timescale;
        NSTimeInterval totalTime   = CMTimeGetSeconds(playerItem.duration);
        weakSelf.timeLabel.text = [NSString stringWithFormat:@"%@/%@",[weakSelf timeToStringWithTimeInterval:currentTime],[weakSelf timeToStringWithTimeInterval:totalTime]];
        weakSelf.progressSlide.value = currentTime/totalTime;
        if (currentTime>=totalTime-1) {
            weakSelf.stopOrPlayBtn.selected = YES;
        }
        NSLog(@"%f --- %f",currentTime,totalTime);
    }];
    
}

/** 转换播放时间和总时间的方法 */
-(NSString *)timeToStringWithTimeInterval:(NSTimeInterval)interval;
{
    NSInteger Min = interval / 60;
    NSInteger Sec = (NSInteger)interval % 60;
    NSString *intervalString = [NSString stringWithFormat:@"%02ld:%02ld",Min,Sec];
    return intervalString;
}
#pragma mark -- 外部方法
+(instancetype)createPlayerWithFrame:(CGRect)frame{
    videoPlayer = [[NSBundle mainBundle] loadNibNamed:@"MyVideoPlayer" owner:nil options:nil].firstObject;
    videoPlayer.originFrame = frame;
    videoPlayer.frame = frame;
    return videoPlayer;
}

-(void)setVideoUrl:(NSURL *)videoUrl{
    _videoUrl = videoUrl;
    [self createAVPlayer];
}

#pragma makr -- 代理方法及kvo
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        //取出status的新值
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey]intValue];
        switch (status) {
            case AVPlayerItemStatusFailed:
                NSLog(@"item 有误");
                break;
            case AVPlayerItemStatusReadyToPlay:
                NSLog(@"准好播放了");
                break;
            case AVPlayerItemStatusUnknown:
                NSLog(@"视频资源出现未知错误");
                break;
            default:
                break;
        }
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
        NSLog(@"缓存不够");
        [self showActivity];
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
        NSLog(@"缓存够了");
        [self hidenActivity];
    }

}
#pragma mark--点击事件

- (IBAction)stopOrPlayBtnClick:(UIButton *)sender {
    [self createStatusTimer];
    if (sender.selected) {
        [self.player play];
    }else{
        [self.player pause];
    }
    sender.selected = !sender.selected;
}

- (IBAction)bigOrSmallBtnClick:(UIButton *)sender {
    if (sender.selected) {
        [UIView animateWithDuration:0.2 animations:^{
            videoPlayer.frame = self.originFrame;
            [self layoutSubviews];
        }];
        self.playerLayer.frame = self.bounds;
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            videoPlayer.frame = [UIScreen mainScreen].bounds;
            [self layoutSubviews];
        }];
        self.playerLayer.frame = self.bounds;
    }
    
    sender.selected = !sender.selected;
    [self createStatusTimer];
}

- (IBAction)progressSlideValueChanged:(UISlider *)sender {
    [self createStatusTimer];
    NSTimeInterval currentTime = CMTimeGetSeconds(self.playerItem.duration)*sender.value;
    [self.player seekToTime:CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    NSTimeInterval totalTime   = CMTimeGetSeconds(self.playerItem.duration);
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@",[self timeToStringWithTimeInterval:currentTime],[self timeToStringWithTimeInterval:totalTime]];
    [self.player play];
}
@end
