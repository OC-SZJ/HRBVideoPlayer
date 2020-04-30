//
//  HRBVideoPlayerBottomOption.h
//  HRBVideoPlayer
//
//  Created by SZJ on 2020/1/20.
//  Copyright © 2020 SZJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface HRBVideoPlayerBottomOption : NSObject
/*
  播放按钮的图片
 */
@property (nonatomic,strong) UIImage * playImage;
/*
  暂停按钮的图片
 */
@property (nonatomic,strong) UIImage * pauseImage;
/*
  进度条 已进行的颜色
 */
@property (nonatomic,strong) UIColor * minTrackColor;
/*
  进度条 未进行的颜色
 */
@property (nonatomic,strong) UIColor * maxTrackColor;
/*
  缓存的颜色
 */
@property (nonatomic,strong) UIColor * bufferColor;
///*
//  进度条 滑块颜色
// */
//@property (nonatomic,strong) UIColor * thumbColor;
/*
  是否显示 下方视图 默认显示  0 不显示  1 显示
 */
@property (nonatomic,copy) NSString * showBottomView;
/*
  是否显示全屏按钮
 */

@property (nonatomic,copy) NSString * needFullScreen;
/*
  下面视图的 背景颜色
 */
@property (nonatomic,strong) UIColor * bottomViewBackgroundColor;
@end

NS_ASSUME_NONNULL_END
