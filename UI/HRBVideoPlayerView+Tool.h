//
//  HRBVideoPlayerView+Tool.h
//  HRBVideoPlayer
//
//  Created by SZJ on 2020/1/20.
//  Copyright © 2020 SZJ. All rights reserved.
//

#import "HRBVideoPlayerView.h"


#import "HRBVideoPlayerTopOption.h"
#import "HRBVideoPlayerBottomOption.h"
#import "HRBVideoPlayerPlayOption.h"
#import "AFNetworkActivityIndicatorManager.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "AFNetworking.h"
#import "UIImage+Gradient.h"

NS_ASSUME_NONNULL_BEGIN

@interface HRBVideoPlayerView (Tool)

NSString * LVP_TimeformatFromSeconds(NSInteger seconds);
/*
  添加通知
 */
- (void)addNotifications;
/*
  移除通知
 */
- (void)removeNotifications ;

/*
  监听网络状态
 */
-(void)netWorkChangeEvent;
/*
  创建计时器
 */
- (void)creatTimer;


- (UIImage *)backImageIsTop:(BOOL)isTop withColor:( UIColor *)color;
@end

NS_ASSUME_NONNULL_END
