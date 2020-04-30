//
//  AppDelegate+HRBVideoPlayer.m
//  FrameWork
//
//  Created by SZJ on 2020/4/23.
//  Copyright © 2020 SZJ. All rights reserved.
//

#import "AppDelegate+HRBVideoPlayer.h"
#import <objc/runtime.h>
@implementation AppDelegate (HRBVideoPlayer)

static NSString *lvp_allowRotation = @"allowRotation";

-(void)setAllowRotation:(BOOL)allowRotation{
    objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(lvp_allowRotation), @(allowRotation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)allowRotation{
    NSNumber * lvp_allowRotation_ = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(lvp_allowRotation));
  return  lvp_allowRotation_.boolValue;
}


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window{
    
    if (self.allowRotation == YES) {
        //横屏
        return UIInterfaceOrientationMaskLandscape;
        
    }else{
        //竖屏
        return UIInterfaceOrientationMaskPortrait;
        
    }
    
}
@end
