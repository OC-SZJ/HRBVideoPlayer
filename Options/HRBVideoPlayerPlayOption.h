//
//  HRBVideoPlayerPlayOption.h
//  HRBVideoPlayer
//
//  Created by SZJ on 2020/1/20.
//  Copyright © 2020 SZJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HRBVideoPlayerPlayOption : NSObject
/*
  需要监听网络变化  默认不监听
 */
@property (nonatomic,assign) BOOL needMonitorNetworkStateChange;
/*
  视频地址
 */
@property (nonatomic,copy) NSString * url;

/*
  自动播放 默认为 不播放
 */
@property (nonatomic,assign) BOOL autoPlay;
@end

NS_ASSUME_NONNULL_END
