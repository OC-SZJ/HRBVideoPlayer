//
//  HRBVideoPlayerView.m
//  HRBVideoPlayer
//
//  Created by SZJ on 2020/1/20.
//  Copyright © 2020 SZJ. All rights reserved.
//

#import "HRBVideoPlayerView.h"

#import "HRBVideoPlayerView+Tool.h"

#import "AppDelegate+HRBVideoPlayer.h"
/*
   2秒钟 收回 上下View
 */
static const float _uiTime = 2.f;

@implementation HRBVideoPlayerView
{
   /*
      UI
    */
    /*
      上面的  父视图
     */
    __weak IBOutlet UIView *_top_view;
    /*
      上面的背景色
     */
    __weak IBOutlet UIImageView *_topBack_imageView;
    /*
      上面的标题
     */
    __weak IBOutlet UILabel *_title_label;
    /*
      上面的返回按钮
     */
    __weak IBOutlet UIButton *_returnBack_button;
    /*
      下面的  父视图
     */
    __weak IBOutlet UIView *_bottom_view;
    /*
      下面的背景色
     */
    __weak IBOutlet UIImageView *_bottomBack_imageView;
    /*
      播放按钮
     */
    __weak IBOutlet UIButton *_play_button;
    /*
      总时长
     */
    __weak IBOutlet UILabel *_allTime_label;
    /*
      进度条
     */
    __weak IBOutlet UISlider *_progress_slider;
    /*
      进度条背景色
     */
    __weak IBOutlet UIView *_progressBack_view;
    
    /*
      进度条缓存
     */
    __weak IBOutlet UIView *_progressBuffer_view;
    __weak IBOutlet NSLayoutConstraint *_buffer_width;
    /*
     全屏按钮
     */
    __weak IBOutlet UIButton *_fullScreen_button;
    /*
      当前时间
     */
    __weak IBOutlet UILabel *_currentTime_label;
    
    /*
       加载状态  提示  视图
     */
    __weak IBOutlet UIView *_load_view;
    /*
      加载状态的风火轮
     */
    __weak IBOutlet UIActivityIndicatorView *_load_activity;
    
    
    
    /*
     视频 设置 及 状态
     */
    /*
      播放设置
     */
    HRBVideoPlayerPlayOption *_playOption;
    /*
      播放器
     */
    IJKFFMoviePlayerController *_playVC;
    /*
      播放状态回调
     */
    void(^_playSateChangeCallBack)(HRBVideoPlayerPlayState state);
    /*
      网络状态回调
     */
    void(^_networkChangeCallBack)(HRBVideoPlayerNetworkState state);
    /*
      时间前进的回调
     */
    void(^_timeChangeCallBack)(void);
    /*
      当前收回UI的时间
     */
    float _currentUITime;
    /*
      0  没有进行拖拽  1 开始拖拽  2 结束拖拽
     */
    NSInteger _seekType;
    /*
      是否正在播放
     */
    BOOL _isPlaying;
    
    /*
      小屏时 父视图
     */
    UIView *_mySuperView;
    /*
      小屏时 的 大小
     */
    CGRect _currentFrame;
}
@synthesize moviePlayer = _playVC;
@synthesize option = _playOption;
@synthesize playStateChange = _playSateChangeCallBack;
@synthesize networkStateChange = _networkChangeCallBack;
@synthesize timeStateChange = _timeChangeCallBack;

#pragma mark --- 生命周期 及  初始化 ---

+(instancetype)shareWithFrame:(CGRect)frame option:(HRBVideoPlayerPlayOption *)option{
    HRBVideoPlayerView *view = [[NSBundle mainBundle] loadNibNamed:@"HRBVideoPlayerView" owner:nil options:nil].firstObject;
    view.frame = frame;
    view->_currentFrame = frame;
    [view UI];
    view->_playOption = option;
    [view prepareToPlayer];
    [view callBacks];
    [view creatTimer];
    return view;
}



-(void)didMoveToWindow{
    [super didMoveToWindow];
    if (!_mySuperView) {
        _mySuperView = self.superview;
    }
    
    if (!_playVC.isPlaying) {
        _load_view.hidden = NO;
        [_load_activity startAnimating];
    }
}

-(void)dealloc{
    [self removeNotifications];
}

#pragma mark --- 各种设置 ---
/*
  回调
 */

- (void)callBacks{
    __weak typeof(self) weakSelf = self;
   
    _playSateChangeCallBack = ^(HRBVideoPlayerPlayState state){
        __strong typeof(self) strongSelf = weakSelf;
        /*
          如果是加载完成 没有设置自动播放 那么 就暂停
         */
        
        if (HRBVideoPlayerPlayState_Loaded == state ) {
            strongSelf->_load_view.hidden = YES;
            [strongSelf->_load_activity stopAnimating];
            if (strongSelf->_seekType == _uiTime) {
                [strongSelf play];
                strongSelf->_seekType = 0;
            }
            if (!strongSelf->_isPlaying) {
                [strongSelf pause];
            }
           strongSelf->_allTime_label.text = LVP_TimeformatFromSeconds(strongSelf->_playVC.duration);
        }
        if (HRBVideoPlayerPlayState_Playing == state) {
            strongSelf->_load_view.hidden = YES;
            [strongSelf->_load_activity stopAnimating];
           
        }
        
        if (HRBVideoPlayerPlayState_Loading == state) {
            strongSelf->_load_view.hidden = NO;
            [strongSelf->_load_activity startAnimating];
        }
      
    };
    _networkChangeCallBack = ^(HRBVideoPlayerNetworkState state){
        __strong typeof(self) strongSelf = weakSelf;
    };
    
    _timeChangeCallBack = ^(){
       __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf->_playVC.isPlaying) {
            strongSelf->_progress_slider.value = strongSelf->_playVC.currentPlaybackTime / strongSelf->_playVC.duration;
            strongSelf->_currentTime_label.text = LVP_TimeformatFromSeconds(strongSelf->_playVC.currentPlaybackTime);
            strongSelf->_currentUITime++;
        }else{
            strongSelf->_currentUITime = 0.f;
        }
        
        [strongSelf changeUIForTimeChange];
        
        if (strongSelf->_playVC.duration > 0) {
            CGFloat width = strongSelf->_progress_slider.frame.size.width * strongSelf->_playVC.playableDuration / strongSelf->_playVC.duration;
            strongSelf->_buffer_width.constant = width;
        }else{
            strongSelf->_buffer_width.constant = 0;
        }
        
        
    };
}

/*
  UI设置
 */
- (void)UI{
    /*
      创建上方 背景色
     */
    _topBack_imageView.image = [self backImageIsTop:YES withColor:nil];
    /*
         创建下方 背景色
        */
    _bottomBack_imageView.image = [self backImageIsTop:NO withColor:nil];


    // 通常状态下
    [_progress_slider setThumbImage:[UIImage imageNamed:@"HRB_v_sliderCircular_small"] forState:UIControlStateNormal];

    // 滑动状态下
    [_progress_slider setThumbImage:[UIImage imageNamed:@"HRB_v_sliderCircular_big"] forState:UIControlStateHighlighted];
    
    _load_view.layer.cornerRadius = 5;
    _load_view.layer.masksToBounds = YES;
    
    
}
/*
  播放器设置
 */
- (void)prepareToPlayer{
    //IJKplayer属性参数设置
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
     //硬解🐴
    [options setOptionIntValue:0 forKey:@"videotoolbox" ofCategory:kIJKFFOptionCategoryPlayer];
    [options setPlayerOptionIntValue:5      forKey:@"framedrop"];
    
    
    NSURL *url = [NSURL URLWithString:_playOption.url];
    
    _playVC = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:options];
    [_playVC setScalingMode:IJKMPMovieScalingModeAspectFit];
    [_playVC setPlayerOptionIntValue:20 * 1024 * 1024 forKey:@"max-buffer-size"];
    _playVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _playVC.view.frame =  self.bounds;
    _playVC.shouldAutoplay = NO;
    [_playVC prepareToPlay];
    
    
    
    [self addSubview:_playVC.view];
    [self sendSubviewToBack:_playVC.view];

  
    
    [self addNotifications];
    
    //添加手势监听
    UITapGestureRecognizer * tap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    tap.numberOfTapsRequired = 1;
    [_playVC.view addGestureRecognizer:tap];
    
     UITapGestureRecognizer * doubleTap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [_playVC.view addGestureRecognizer:doubleTap];
    
    [tap requireGestureRecognizerToFail:doubleTap];
}



#pragma mark --- 各种事件 ---
/*
  点击播放/暂停
 */
- (IBAction)play:(UIButton *)sender {
    if (!_playVC.isPlaying) {
        [self play];
    }else{
        [self pause];
    }
}
/*
  根据时间 来判断UI 显示 还是隐藏
 */
- (void)changeUIForTimeChange{
    if (_currentUITime == _uiTime) [self hideUI];
    if (_currentUITime < _uiTime) [self showUI];
}
/*
  单击
 */
- (void)tap:(UITapGestureRecognizer *)tap{
    _currentUITime = -1.f;
    [self showUI];
}
/*
  双击
 */
- (void)doubleTap:(UITapGestureRecognizer *)tap{
    if (!_playVC.isPlaying) {
        [self play];
    }else{
        [self pause];
    }
    
}
/*
  显示UI
 */
- (void)showUI{
    [_top_view.layer removeAllAnimations];
    [_bottom_view.layer removeAllAnimations];
    _top_view.transform = CGAffineTransformMakeTranslation(0, 0);
    _bottom_view.transform = CGAffineTransformMakeTranslation(0, 0);
}
/*
  隐藏UI
 */
- (void)hideUI{
    [_top_view.layer removeAllAnimations];
    [_bottom_view.layer removeAllAnimations];
    [UIView animateWithDuration:1 animations:^{
        self->_top_view.transform = CGAffineTransformMakeTranslation(0, -44);
        self->_bottom_view.transform = CGAffineTransformMakeTranslation(0, 44);
    }];
}
/*
  播放
 */
- (void)play{
    [_playVC play];
    [_play_button setImage:[UIImage imageNamed:@"HRB_v_pause"] forState:UIControlStateNormal];
    _isPlaying = YES;
}
/*
  暂停
 */
- (void)pause{
    [_playVC pause];
    [_play_button setImage:[UIImage imageNamed:@"HRB_v_play"] forState:UIControlStateNormal];
    [self showUI];
    _isPlaying = NO;
}
/*
  拖动进度条
 */
- (IBAction)seek:(UISlider *)sender {
    float value = sender.value;
    _playVC.currentPlaybackTime = value * _playVC.duration;
    _currentTime_label.text = LVP_TimeformatFromSeconds(_playVC.currentPlaybackTime);
    
}
/*
  开始拖动进度条
 */
- (IBAction)beginSeek:(UISlider *)sender {
    _seekType = 1;
    [self pause];
}
/*
  结束拖动进度条
 */
- (IBAction)endSeek:(UISlider *)sender {
    _seekType = 2;
}
/*
  全屏/半瓶
 */
- (IBAction)fullScreen:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    /*
      半屏
     */
    delegate.allowRotation = NO;
    if (self.frame.size.width != _currentFrame.size.width) {
        [UIView animateWithDuration:0.25 animations:^{
            [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];

        }completion:^(BOOL finished) {
            self.frame = self->_currentFrame;
            [self removeFromSuperview];
            [self->_mySuperView addSubview:self];
             [self refreshTopAndBottomViewBack];
        }];
    }else{
        /*
          全屏
         */
        delegate.allowRotation = YES;
        [UIView animateWithDuration:0.25 animations:^{
            [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
            
        }completion:^(BOOL finished) {
            self.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
            [self removeFromSuperview];
            [[UIApplication sharedApplication].keyWindow addSubview:self];
            [self refreshTopAndBottomViewBack];
        }];
    }
}
/*
  切换 全屏和 半屏的时候 刷新上下view的背景
 */
- (void)refreshTopAndBottomViewBack{
    
    _topBack_imageView.image = [self backImageIsTop:YES withColor:_topOption.topViewBackgroundColor];
    _bottomBack_imageView.image = [self backImageIsTop:NO withColor:_bottomOption.bottomViewBackgroundColor];
}


#pragma mark --- getter 和  setter ---

-(void)setTopOption:(HRBVideoPlayerTopOption *)topOption{
    _topOption = topOption;
    
    /*
      是否显示返回按钮
     */
    _returnBack_button.hidden = [topOption.needReturnBackButton isEqualToString:@"0"];
    /*
      标题
     */
    _title_label.text = topOption.title ? topOption.title : @"视频";
    /*
      返回图标
     */
    if (topOption.returnBackImage) {
        [_returnBack_button setImage:topOption.returnBackImage forState:UIControlStateNormal];
    }
    
    _top_view.hidden = [topOption.showTopView isEqualToString:@"0"];
    

    _topBack_imageView.image = [self backImageIsTop:YES withColor:topOption.topViewBackgroundColor];
    
}

-(void)setBottomOption:(HRBVideoPlayerBottomOption *)bottomOption{
    _bottomOption = bottomOption;
    
    if (bottomOption.minTrackColor) {
        _progress_slider.minimumTrackTintColor = bottomOption.minTrackColor;
    }
    if (bottomOption.maxTrackColor) {
       _progressBack_view.backgroundColor = bottomOption.maxTrackColor;
    }
    if (bottomOption.bufferColor) {
        _progressBuffer_view.backgroundColor = bottomOption.bufferColor;
    }
//    if (bottomOption.thumbColor) {
//        _progress_slider.thumbTintColor = bottomOption.thumbColor;
//    }
    
    _bottom_view.hidden = [bottomOption.showBottomView isEqualToString:@"0"];
    _fullScreen_button.hidden = [bottomOption.needFullScreen isEqualToString:@"0"];
    
    
    _bottomBack_imageView.image = [self backImageIsTop:NO withColor:bottomOption.bottomViewBackgroundColor];
    
}

-(NSInteger)currentDuration{
    return self.moviePlayer.playableDuration;
}




@end
