//
//  HRBVideoPlayerView.h
//  HRBVideoPlayer
//
//  Created by SZJ on 2020/1/20.
//  Copyright © 2020 SZJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HRBVideoPlayerTopOption;
@class HRBVideoPlayerBottomOption;
@class HRBVideoPlayerPlayOption;
@class IJKFFMoviePlayerController;



typedef NS_ENUM(NSInteger, HRBVideoPlayerPlayState) {
    /*
      未知状态
     */
    HRBVideoPlayerPlayState_Unknown   = -1,
    /*
     加载中
     */
    HRBVideoPlayerPlayState_Loading =  -2,
    /*
     加载完成
     */
    HRBVideoPlayerPlayState_Loaded =  -3,
    /*
      停止加载
     */
    HRBVideoPlayerPlayState_stopLoading = -4,
    /*
      播放出错
     */
    HRBVideoPlayerPlayState_Error = -5,
    /*
      播放中
     */
    HRBVideoPlayerPlayState_Playing     = 0,
    /*
      播放结束
     */
    HRBVideoPlayerPlayState_Finish = 1,
    /*
      播放暂停
     */
    HRBVideoPlayerPlayState_Pause = 2,
    
};

typedef NS_ENUM(NSInteger, HRBVideoPlayerNetworkState) {
    /*
      断网
     */
    HRBVideoPlayerNetworkState_noNetwork          = 0,
    /*
     wifi
     */
    HRBVideoPlayerNetworkState_WIFI ,
    /*
      流量
     */
    HRBVideoPlayerNetworkState_WAN ,
    
};
NS_ASSUME_NONNULL_BEGIN

@interface HRBVideoPlayerView : UIView
/*
  上方  视图的设置
 */
@property (nonatomic,strong) HRBVideoPlayerTopOption * topOption;
/*
  下方  视图的设置
 */
@property (nonatomic,strong) HRBVideoPlayerBottomOption * bottomOption;
/*
  当前播放时长
 */
@property (nonatomic,assign) NSInteger currentDuration;
/*
 初始化
 */
+(instancetype)shareWithFrame:(CGRect)frame option:(HRBVideoPlayerPlayOption *)option;


#pragma mark - 以下为私有属性
/*
  视频播放器
 */
@property (nonatomic,strong,readonly) IJKFFMoviePlayerController * moviePlayer;
/*
  播放设置
 */
@property (nonatomic,strong,readonly) HRBVideoPlayerPlayOption * option;
/*
  播放状态 改变回调
 */
@property (nonatomic,copy,readonly) void(^playStateChange)(HRBVideoPlayerPlayState state);
/*
  网络状态 改变回调
 */
@property (nonatomic,copy,readonly) void(^networkStateChange)(HRBVideoPlayerNetworkState state);

@property (nonatomic,copy,readonly)void(^timeStateChange)(void);

@end

NS_ASSUME_NONNULL_END
