//
//  HRBVideoPlayerTopOption.h
//  HRBVideoPlayer
//
//  Created by SZJ on 2020/1/20.
//  Copyright © 2020 SZJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface HRBVideoPlayerTopOption : NSObject
/*
  返回键的按钮
 */
@property (nonatomic,strong) UIImage  * returnBackImage;
/*
  上面视图的 背景颜色
 */
@property (nonatomic,strong) UIColor * topViewBackgroundColor;
/*
  是否需要显示返回按钮  默认 显示   0 不显示  1 显示
 */
@property (nonatomic,copy) NSString * needReturnBackButton;
/*
  视频标题
 */
@property (nonatomic,copy) NSString * title;
/*
  是否显示上方的视图  默认 显示  0 不显示  1 显示
 */
@property (nonatomic,copy) NSString * showTopView;

@end

NS_ASSUME_NONNULL_END
