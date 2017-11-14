//
//  KNBPartPresentationController.m
//  SobotKit
//
//  Created by suojl on 2017/11/6.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "KNBPartPresentationController.h"
#import "ZCLIbGlobalDefine.h"

@implementation KNBPartPresentationController
{
    UIControl* dimmingView;
}

/**呈现弹出开始*/
- (void)presentationTransitionWillBegin{
    [super presentationTransitionWillBegin];

    if (!dimmingView) {
        dimmingView = [[UIControl alloc] initWithFrame:self.containerView.bounds];
    }
    dimmingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    dimmingView.alpha = 0;

    [self.containerView addSubview:dimmingView];//设置转场动画的背景
    if (_shouldDismissWhenTap) {//点击背景是否关闭
        [dimmingView addTarget:self action:@selector(closePresentedVC) forControlEvents:UIControlEventTouchUpInside];
    }
    //调整背景透明度
    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id anima){

        dimmingView.alpha = 1;
    } completion:nil];
}
/**呈现弹出结束*/
- (void)presentationTransitionDidEnd:(BOOL)completed{
    if (!completed) { // 过程失败
        [dimmingView removeFromSuperview];
    }
}
/**解除呈现开始*/
- (void)dismissalTransitionWillBegin{

    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id anima){
        dimmingView.alpha = 0;
    } completion:nil];
}
/**解除呈现结束*/
- (void)dismissalTransitionDidEnd:(BOOL)completed{
    if (completed) {
        [dimmingView removeFromSuperview];
    }
}
// 返回将要呈现的视图的最终Rect
-(CGRect)frameOfPresentedViewInContainerView{

//    CGFloat viewHeight = self.containerView.frame.size.height;
    CGRect finalRect = CGRectOffset(self.containerView.frame, 0, (ScreenHeight - 273));
    return finalRect;
}

-(void)closePresentedVC{
    DLog(@"---%@",[self.presentingViewController class]);
    DLog(@"---%@",[self.presentedViewController class]);
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];;
}
-(void)dealloc{

    dimmingView = nil;
}
@end
