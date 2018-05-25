//
//  MyVideoPlayer.h
//  AVPlayer
//
//  Created by Yang on 2018/5/25.
//  Copyright © 2018年 Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyVideoPlayer : UIView

+(instancetype)createPlayerWithFrame:(CGRect)frame;

@property(nonatomic,strong)NSURL *videoUrl;//播放路径
@end
