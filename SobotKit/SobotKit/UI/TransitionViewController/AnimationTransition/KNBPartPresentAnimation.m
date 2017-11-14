//
//  KNBPartPresentAnimation.m
//  SobotKit
//
//  Created by suojl on 2017/11/6.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "KNBPartPresentAnimation.h"
#import "ZCLIbGlobalDefine.h"

@implementation KNBPartPresentAnimation

- (id)init {
    if (self = [super init]) {
        self.duration = 0.5f;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return self.duration;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{

    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    // 展现动画的容器视图
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];

    if (self.reverse) {

        // 获取视图最终的frame
        CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
        CGRect initFrame = CGRectOffset(finalFrame, 0, (ScreenHeight/2));
        toVC.view.frame = initFrame;    // 设置视图为最终frame,即自动布局完成后的状态

        [containerView addSubview:toVC.view];
        [UIView animateWithDuration:1.0 animations:^{
            toVC.view.frame = finalFrame;
        } completion:^(BOOL finished) {
            // 5. Tell context that we completed.
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }else{
        CGRect initFrame = [transitionContext initialFrameForViewController:fromVC];
        CGRect finalFrame = CGRectOffset(initFrame, 0, (ScreenHeight/2 - 47)-50);

        [containerView addSubview:fromVC.view];

        [UIView animateWithDuration:duration animations:^{
            fromVC.view.frame = finalFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }

}
@end
