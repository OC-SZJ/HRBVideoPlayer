//
//  HRBVideoPlayerView+Tool.m
//  HRBVideoPlayer
//
//  Created by SZJ on 2020/1/20.
//  Copyright © 2020 SZJ. All rights reserved.
//

#import "HRBVideoPlayerView+Tool.h"

#import <objc/runtime.h>

@implementation HRBVideoPlayerView (Tool)
#pragma mark - 把时间转换成为时分秒
NSString * LVP_TimeformatFromSeconds(NSInteger seconds)
{
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    return format_time;
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(seekCompletedEvent) name:IJKMPMoviePlayerDidSeekCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(play) name:UIApplicationDidBecomeActiveNotification object:nil];
}
#pragma mark - 移除通知
- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:IJKMPMoviePlayerDidSeekCompleteNotification
                                                 object:nil];
}

/*
  加载状态变化
 */
- (void)loadStateDidChange:(NSNotification*)notification
{
    IJKMPMovieLoadState loadState = self.moviePlayer.loadState;
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) !=0) {
        NSLog(@"🍉 加载状态变成了已经缓存完成，如果设置了自动播放，这时会自动播放");
        self.playStateChange(HRBVideoPlayerPlayState_Loaded);
    }
    if ((loadState & IJKMPMovieLoadStateStalled) != 0)
    {
        NSLog(@"🍉 加载状态变成了数据缓存已经停止，播放将暂停");
         self.playStateChange(HRBVideoPlayerPlayState_Loading);
        
    }
    if((loadState & IJKMPMovieLoadStatePlayable) != 0)
    {
        NSLog(@"🍉 加载状态变成了缓存数据足够开始播放，但是视频并没有缓存完全");
        
        
        
    }
    if ((loadState & IJKMPMovieLoadStateUnknown) != 0) {
        NSLog(@"🍉 加载状态变成了未知状态");
        self.playStateChange(HRBVideoPlayerPlayState_Unknown);
    }
}

/*
  播放完成
 */
- (void)moviePlayBackFinish:(NSNotification*)notification
{
    int reason = [[[notification userInfo]valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason) {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"🍉 播放状态改变了：现在是播放完毕的状态：%d",reason);
            self.playStateChange(HRBVideoPlayerPlayState_Finish);
            
            break;
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"🍉 播放状态改变了：现在是用户退出状态：%d",reason);
            self.playStateChange(HRBVideoPlayerPlayState_Finish);
            break;
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"🍉 播放状态改变了：现在是播放错误状态：%d",reason);
            self.playStateChange(HRBVideoPlayerPlayState_Error);
            break;
        default:
            
            break;
    }
}


- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"🍉 加载状态发生改变");

   
}




#pragma mark - 加载完成的方法
-(void)seekCompletedEvent
{
    NSLog(@"🍉 加载完成");
}



#pragma mark - 视频播放器状态改变
- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    switch (self.moviePlayer.playbackState) {
        case IJKMPMoviePlaybackStateStopped:
           
           self.playStateChange(HRBVideoPlayerPlayState_Finish); NSLog(@"🍉 播放器的播放状态变了，现在是停止状态:%d",(int)self.moviePlayer.playbackState);
            break;
        case IJKMPMoviePlaybackStatePlaying:
           
           self.playStateChange(HRBVideoPlayerPlayState_Playing); NSLog(@"🍉 播放器的播放状态变了，现在是播放状态:%d",(int)self.moviePlayer.playbackState);
            break;
        case IJKMPMoviePlaybackStatePaused:
            
            self.playStateChange(HRBVideoPlayerPlayState_Pause); NSLog(@"🍉 播放器的播放状态变了，现在是暂停状态:%d",(int)self.moviePlayer.playbackState);
            break;
        case IJKMPMoviePlaybackStateInterrupted:
           self.playStateChange(HRBVideoPlayerPlayState_Loading); NSLog(@"🍉 播放器的播放状态变了，现在是中断状态:%d",(int)self.moviePlayer.playbackState);
            
            break;
        case IJKMPMoviePlaybackStateSeekingForward:
            self.playStateChange(HRBVideoPlayerPlayState_Pause); NSLog(@"🍉 播放器的播放状态变了，现在是向前拖动状态:%d",(int)self.moviePlayer.playbackState);
            
//            self.playerOption.currenTime = self.moviePlayer.currentPlaybackTime;
            
            break;
            
        case IJKMPMoviePlaybackStateSeekingBackward:
              self.playStateChange(HRBVideoPlayerPlayState_Pause);
            NSLog(@"🍉 播放器的播放状态变了，现在是向后拖动状态：%d",(int)self.moviePlayer.playbackState);
            break;
        default:
            self.playStateChange(HRBVideoPlayerPlayState_Unknown);
            NSLog(@"🍉 播放器的播放状态变了，现在是未知状态：%d",(int)self.moviePlayer.playbackState);
            break;
    }
}



/*
  监听网络状态
 */
-(void)netWorkChangeEvent
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    NSURL *url = [NSURL URLWithString:@"http://baidu.com"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"当前使用的是流量模式");
                self.networkStateChange(HRBVideoPlayerNetworkState_WAN);
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                self.networkStateChange(HRBVideoPlayerNetworkState_WIFI);
                NSLog(@"当前使用的是wifi模式");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"断网了");
                self.networkStateChange(HRBVideoPlayerNetworkState_noNetwork);
                break;
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"变成了未知网络状态");
                self.networkStateChange(HRBVideoPlayerNetworkState_noNetwork);
                break;
                
            default:
                break;
        }
    }];
    [manager.reachabilityManager startMonitoring];
}

- (void)creatTimer{
    __weak typeof(self) weakSelf = self;
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
      NSRunLoop *runloop =  [NSRunLoop currentRunLoop];
      NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            __strong typeof(self)strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!strongSelf) {
                    CFRunLoopStop(runloop.getCFRunLoop);
                }else{
                    strongSelf.timeStateChange();
                }
                
            });
        }];
      [runloop addTimer:timer forMode:NSDefaultRunLoopMode];
      [runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }];
    [thread start];
}

- (UIImage *)backImageIsTop:(BOOL)isTop withColor:(UIColor *)color{
    if (!color) {
        color = UIColor.blackColor;
    }
    UIImage *i = [self createImageWithSize:CGSizeMake(self.frame.size.width, 46) gradientColors:@[[color colorWithAlphaComponent:isTop ? 0.6 : 0.2],[color colorWithAlphaComponent:isTop ? 0.2 : 0.6]] percentage:@[@0.3,@1] gradientType: GradientFromTopToBottom];
    
    return i;
}
- (UIImage *)createImageWithSize:(CGSize)imageSize gradientColors:(NSArray *)colors percentage:(NSArray *)percents gradientType:(GradientType)gradientType {
    
    NSAssert(percents.count <= 5, @"输入颜色数量过多，如果需求数量过大，请修改locations[]数组的个数");
    
    NSMutableArray *ar = [NSMutableArray array];
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }

    CGFloat locations[5];
    for (int i = 0; i < percents.count; i++) {
        locations[i] = [percents[i] floatValue];
    }
    
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, locations);
    CGPoint start;
    CGPoint end;
    switch (gradientType) {
        case GradientFromTopToBottom:
            start = CGPointMake(imageSize.width/2, 0.0);
            end = CGPointMake(imageSize.width/2, imageSize.height);
            break;
        case GradientFromLeftToRight:
            start = CGPointMake(0.0, imageSize.height/2);
            end = CGPointMake(imageSize.width, imageSize.height/2);
            break;
        case GradientFromLeftTopToRightBottom:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(imageSize.width, imageSize.height);
            break;
        case GradientFromLeftBottomToRightTop:
            start = CGPointMake(0.0, imageSize.height);
            end = CGPointMake(imageSize.width, 0.0);
            break;
        default:
            break;
    }
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}
@end
